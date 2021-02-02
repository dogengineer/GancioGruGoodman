% Autore: Davide Maieron
% Data: 02 Febbraio 2021
% Licenza: leggere il file "LICENSE" allegato

classdef gru_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        Image                           matlab.ui.control.Image
        CaricoPtonnellateLabel          matlab.ui.control.Label
        CaricoPtonnellateEditField      matlab.ui.control.NumericEditField
        RaggiointernorimmEditFieldLabel  matlab.ui.control.Label
        RaggiointernorimmEditField      matlab.ui.control.NumericEditField
        RaggioesternoremmEditFieldLabel  matlab.ui.control.Label
        RaggioesternoremmEditField      matlab.ui.control.NumericEditField
        BaseminoredeltrapezioammEditFieldLabel  matlab.ui.control.Label
        BaseminoredeltrapezioammEditField  matlab.ui.control.NumericEditField
        BasemaggioredeltrapeziobmmEditFieldLabel  matlab.ui.control.Label
        BasemaggioredeltrapeziobmmEditField  matlab.ui.control.NumericEditField
        BasedelrettangolobRmmEditFieldLabel  matlab.ui.control.Label
        BasedelrettangolobRmmEditField  matlab.ui.control.NumericEditField
        EccentricitemmEditFieldLabel    matlab.ui.control.Label
        EccentricitemmEditField         matlab.ui.control.NumericEditField
        TipodisezioneButtonGroup        matlab.ui.container.ButtonGroup
        RettangolareButton              matlab.ui.control.RadioButton
        TrapezioidaleButton             matlab.ui.control.RadioButton
        areamm2EditFieldLabel           matlab.ui.control.Label
        areamm2EditField                matlab.ui.control.NumericEditField
        RUNButton                       matlab.ui.control.Button
        ResistenzaafaticaLampLabel      matlab.ui.control.Label
        ResistenzaafaticaLamp           matlab.ui.control.Lamp
        CoefficientedisnervamentoDropDownLabel  matlab.ui.control.Label
        CoefficientedisnervamentoDropDown  matlab.ui.control.DropDown
        CoefficienteSnervamentoLabel    matlab.ui.control.Label
        sigmanormalenMpaLabel           matlab.ui.control.Label
        sigmanormalenMpaEditField       matlab.ui.control.NumericEditField
        sigmaflessionalefMpaEditFieldLabel  matlab.ui.control.Label
        sigmaflessionalefMpaEditField   matlab.ui.control.NumericEditField
        sigmatotaletotMpaEditFieldLabel  matlab.ui.control.Label
        sigmatotaletotMpaEditField      matlab.ui.control.NumericEditField
        coefficientedisicurezzanEditFieldLabel  matlab.ui.control.Label
        coefficientedisicurezzanEditField  matlab.ui.control.NumericEditField
    end

    
    methods (Access = private)
        
        function rEcc = RaggioEccentrico(~, re, e)
            rEcc=re+e;
        end
        
        function A = AreaTrapezio(app, B, b, re, ri, e)
            rEcc = app.RaggioEccentrico(re, e);
            A =  ((b+B)/2)*(rEcc-ri);
        end
        
        function A = AreaRettangolo(app, b, re, ri, e)
            rEcc = app.RaggioEccentrico(re, e);
            A = b*(rEcc-ri);
        end
        
        function r = RaggioAsseNeutroTrapezio(app, B, b, re, ri, e)
            rEcc = app.RaggioEccentrico(re, e);
            numeratore = (rEcc-b)^2*(b+B);
            denominatore = 2 * ((B*rEcc - b*ri)*log(rEcc/ri)-(B-b)*(rEcc-ri));
            r = (numeratore/denominatore);
        end
        
        function r = RaggioAsseNeutroRettangolo(app,re,ri,e)
            rEcc = app.RaggioEccentrico(re, e);
            r = (rEcc-ri)/(log(rEcc/ri));
        end
        
        function rg = RaggioBaricentricoTrapezio(app,B,b,re,ri,e)
            rEcc = app.RaggioEccentrico(re, e);
            rg = ri+((((rEcc-ri)/3)*(2*b+B))/(b+B));
        end
        
        function rg = RaggioBaricentricoRettangolo(app,re,ri,e)
            rEcc = app.RaggioEccentrico(re, e);
            rg = (ri+rEcc)/2;
        end
        
        %per evitare di scrivere mille volte le variabili e i parametri di
        %posso scrivere così:
        function [A,rN] = CalcolaTrapezio(app, B, b, re, ri, e)
            A = app.AreaTrapezio(B, b, re, ri, e);
            rN = app.RaggioAsseNeutroTrapezio(B, b, re, ri, e);
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: RUNButton
        function RUNButtonPushed(app, event)
            raggioEsterno = app.RaggioesternoremmEditField.Value;
            raggioInterno = app.RaggiointernorimmEditField.Value;
            eccentricita = app.EccentricitemmEditField.Value;
            carico = app.CaricoPtonnellateEditField.Value;
            % converto in newton
            carico = 9806.55*carico;
            
            % Essendo che i dati servono in entrambi i casi,
            % posso acquisire gli stessi prima della condizione.
            if app.TrapezioidaleButton.Value
                baseMaggiore = app.BasemaggioredeltrapeziobmmEditField.Value;
                baseMinore = app.BaseminoredeltrapezioammEditField.Value;
                area = app.AreaTrapezio(baseMaggiore, baseMinore, raggioEsterno, raggioInterno, eccentricita);
                raggioAsseNeutro = app.RaggioAsseNeutroTrapezio(baseMaggiore, baseMinore, raggioEsterno, raggioInterno, eccentricita);
                raggioBaricentrico= app.RaggioBaricentricoTrapezio(baseMaggiore, baseMinore, raggioEsterno, raggioInterno, eccentricita);
            else
                base = app.BasedelrettangolobRmmEditField.Value;
                area = app.AreaRettangolo(base, raggioEsterno, raggioInterno, eccentricita);
                raggioAsseNeutro = app.RaggioAsseNeutroRettangolo(raggioEsterno, raggioInterno, eccentricita);
                raggioBaricentrico = app.RaggioBaricentricoRettangolo(raggioEsterno, raggioInterno, eccentricita);
            end
            sigmaFlessionale = (carico*raggioBaricentrico*(raggioAsseNeutro-raggioInterno))/(area*(raggioBaricentrico-raggioAsseNeutro)*raggioInterno);
            sigmaNormale = carico/area;
            sigmaTotale = sigmaNormale+sigmaFlessionale;
            %il menù a tendina mi scrive i numeri a stringhe, uso
            %str2double per convertire i valori in interi
            coefficienteSnervamento = str2double(app.CoefficientedisnervamentoDropDown.Value);
            coefficienteSicurezza = coefficienteSnervamento/sigmaTotale;
            % Essendo che l'area va scritta in ogni caso, la scrivo solo
            % una volta invece che fare la stessa cosa nei due if.
            app.areamm2EditField.Value = area;
            %msgbox(sprintf("%0.5f", sigmaNormale));
            app.sigmaflessionalefMpaEditField.Value = sigmaFlessionale;
            app.sigmanormalenMpaEditField.Value = sigmaNormale;
            app.sigmatotaletotMpaEditField.Value = sigmaTotale;
            app.coefficientedisicurezzanEditField.Value = coefficienteSicurezza;
            
          
            
            if coefficienteSicurezza > 1.3
                app.ResistenzaafaticaLamp.Color = "green";
            elseif coefficienteSicurezza > 1
                app.ResistenzaafaticaLamp.Color = "#FFA500";
            else
                app.ResistenzaafaticaLamp.Color = "red";
            end
            %coefficienteSnervamento = app.CoefficientedisnervamentoDropDown.Value;
            %msgbox(coefficienteSnervamento);
            %msgbox(sprintf("%0.3f", raggioAsseNeutro));
        end

        % Value changed function: CoefficientedisnervamentoDropDown
        function CoefficientedisnervamentoDropDownValueChanged(app, event)
            value = app.CoefficientedisnervamentoDropDown.Value;
            app.CoefficienteSnervamentoLabel.Text = value;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 686 570];
            app.UIFigure.Name = 'MATLAB App';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [392 295 276 276];
            app.Image.ImageSource = 'gru.png';

            % Create CaricoPtonnellateLabel
            app.CaricoPtonnellateLabel = uilabel(app.UIFigure);
            app.CaricoPtonnellateLabel.HorizontalAlignment = 'center';
            app.CaricoPtonnellateLabel.Position = [113 422 123 22];
            app.CaricoPtonnellateLabel.Text = 'Carico -P- (tonnellate)';

            % Create CaricoPtonnellateEditField
            app.CaricoPtonnellateEditField = uieditfield(app.UIFigure, 'numeric');
            app.CaricoPtonnellateEditField.ValueDisplayFormat = '%11.7g';
            app.CaricoPtonnellateEditField.HorizontalAlignment = 'center';
            app.CaricoPtonnellateEditField.Position = [251 422 100 22];

            % Create RaggiointernorimmEditFieldLabel
            app.RaggiointernorimmEditFieldLabel = uilabel(app.UIFigure);
            app.RaggiointernorimmEditFieldLabel.HorizontalAlignment = 'center';
            app.RaggiointernorimmEditFieldLabel.Position = [103 387 133 22];
            app.RaggiointernorimmEditFieldLabel.Text = 'Raggio interno -ri- (mm)';

            % Create RaggiointernorimmEditField
            app.RaggiointernorimmEditField = uieditfield(app.UIFigure, 'numeric');
            app.RaggiointernorimmEditField.HorizontalAlignment = 'center';
            app.RaggiointernorimmEditField.Position = [251 387 100 22];

            % Create RaggioesternoremmEditFieldLabel
            app.RaggioesternoremmEditFieldLabel = uilabel(app.UIFigure);
            app.RaggioesternoremmEditFieldLabel.HorizontalAlignment = 'center';
            app.RaggioesternoremmEditFieldLabel.Position = [96 348 140 22];
            app.RaggioesternoremmEditFieldLabel.Text = 'Raggio esterno -re- (mm)';

            % Create RaggioesternoremmEditField
            app.RaggioesternoremmEditField = uieditfield(app.UIFigure, 'numeric');
            app.RaggioesternoremmEditField.HorizontalAlignment = 'center';
            app.RaggioesternoremmEditField.Position = [251 348 100 22];

            % Create BaseminoredeltrapezioammEditFieldLabel
            app.BaseminoredeltrapezioammEditFieldLabel = uilabel(app.UIFigure);
            app.BaseminoredeltrapezioammEditFieldLabel.HorizontalAlignment = 'center';
            app.BaseminoredeltrapezioammEditFieldLabel.Position = [48 309 188 22];
            app.BaseminoredeltrapezioammEditFieldLabel.Text = 'Base minore del trapezio -a- (mm)';

            % Create BaseminoredeltrapezioammEditField
            app.BaseminoredeltrapezioammEditField = uieditfield(app.UIFigure, 'numeric');
            app.BaseminoredeltrapezioammEditField.HorizontalAlignment = 'center';
            app.BaseminoredeltrapezioammEditField.Position = [251 309 100 22];

            % Create BasemaggioredeltrapeziobmmEditFieldLabel
            app.BasemaggioredeltrapeziobmmEditFieldLabel = uilabel(app.UIFigure);
            app.BasemaggioredeltrapeziobmmEditFieldLabel.HorizontalAlignment = 'center';
            app.BasemaggioredeltrapeziobmmEditFieldLabel.Position = [34 265 202 22];
            app.BasemaggioredeltrapeziobmmEditFieldLabel.Text = 'Base maggiore del trapezio -b- (mm)';

            % Create BasemaggioredeltrapeziobmmEditField
            app.BasemaggioredeltrapeziobmmEditField = uieditfield(app.UIFigure, 'numeric');
            app.BasemaggioredeltrapeziobmmEditField.HorizontalAlignment = 'center';
            app.BasemaggioredeltrapeziobmmEditField.Position = [251 265 100 22];

            % Create BasedelrettangolobRmmEditFieldLabel
            app.BasedelrettangolobRmmEditFieldLabel = uilabel(app.UIFigure);
            app.BasedelrettangolobRmmEditFieldLabel.HorizontalAlignment = 'center';
            app.BasedelrettangolobRmmEditFieldLabel.Position = [69 224 167 22];
            app.BasedelrettangolobRmmEditFieldLabel.Text = 'Base del rettangolo -bR- (mm)';

            % Create BasedelrettangolobRmmEditField
            app.BasedelrettangolobRmmEditField = uieditfield(app.UIFigure, 'numeric');
            app.BasedelrettangolobRmmEditField.HorizontalAlignment = 'center';
            app.BasedelrettangolobRmmEditField.Position = [251 224 100 22];

            % Create EccentricitemmEditFieldLabel
            app.EccentricitemmEditFieldLabel = uilabel(app.UIFigure);
            app.EccentricitemmEditFieldLabel.HorizontalAlignment = 'center';
            app.EccentricitemmEditFieldLabel.Position = [119 186 117 22];
            app.EccentricitemmEditFieldLabel.Text = 'Eccentricità -e- (mm)';

            % Create EccentricitemmEditField
            app.EccentricitemmEditField = uieditfield(app.UIFigure, 'numeric');
            app.EccentricitemmEditField.HorizontalAlignment = 'center';
            app.EccentricitemmEditField.Position = [251 186 100 22];

            % Create TipodisezioneButtonGroup
            app.TipodisezioneButtonGroup = uibuttongroup(app.UIFigure);
            app.TipodisezioneButtonGroup.TitlePosition = 'centertop';
            app.TipodisezioneButtonGroup.Title = 'Tipo di sezione';
            app.TipodisezioneButtonGroup.Position = [119 479 232 67];

            % Create RettangolareButton
            app.RettangolareButton = uiradiobutton(app.TipodisezioneButtonGroup);
            app.RettangolareButton.Text = 'Rettangolare ';
            app.RettangolareButton.Position = [11 21 94 22];
            app.RettangolareButton.Value = true;

            % Create TrapezioidaleButton
            app.TrapezioidaleButton = uiradiobutton(app.TipodisezioneButtonGroup);
            app.TrapezioidaleButton.Text = 'Trapezioidale';
            app.TrapezioidaleButton.Position = [11 -1 94 22];

            % Create areamm2EditFieldLabel
            app.areamm2EditFieldLabel = uilabel(app.UIFigure);
            app.areamm2EditFieldLabel.HorizontalAlignment = 'center';
            app.areamm2EditFieldLabel.Position = [164 107 73 22];
            app.areamm2EditFieldLabel.Text = 'area (mm^2)';

            % Create areamm2EditField
            app.areamm2EditField = uieditfield(app.UIFigure, 'numeric');
            app.areamm2EditField.Editable = 'off';
            app.areamm2EditField.HorizontalAlignment = 'center';
            app.areamm2EditField.Position = [252 107 100 22];

            % Create RUNButton
            app.RUNButton = uibutton(app.UIFigure, 'push');
            app.RUNButton.ButtonPushedFcn = createCallbackFcn(app, @RUNButtonPushed, true);
            app.RUNButton.Position = [471 181 139 32];
            app.RUNButton.Text = 'RUN';

            % Create ResistenzaafaticaLampLabel
            app.ResistenzaafaticaLampLabel = uilabel(app.UIFigure);
            app.ResistenzaafaticaLampLabel.HorizontalAlignment = 'right';
            app.ResistenzaafaticaLampLabel.Position = [524 34 107 22];
            app.ResistenzaafaticaLampLabel.Text = 'Resistenza a fatica';

            % Create ResistenzaafaticaLamp
            app.ResistenzaafaticaLamp = uilamp(app.UIFigure);
            app.ResistenzaafaticaLamp.Position = [646 34 20 20];
            app.ResistenzaafaticaLamp.Color = [0.902 0.902 0.902];

            % Create CoefficientedisnervamentoDropDownLabel
            app.CoefficientedisnervamentoDropDownLabel = uilabel(app.UIFigure);
            app.CoefficientedisnervamentoDropDownLabel.HorizontalAlignment = 'right';
            app.CoefficientedisnervamentoDropDownLabel.Position = [399 264 154 22];
            app.CoefficientedisnervamentoDropDownLabel.Text = 'Coefficiente di snervamento';

            % Create CoefficientedisnervamentoDropDown
            app.CoefficientedisnervamentoDropDown = uidropdown(app.UIFigure);
            app.CoefficientedisnervamentoDropDown.Items = {'C20', 'C30', 'C40', '14CrNi5', '16CrNi4', '38NiCrMo4', '40NiCrMo7', 'gsq42/15', 'ghisa sferoidale'};
            app.CoefficientedisnervamentoDropDown.ItemsData = {'300', '370', '430', '850', '1070', '1000', '1070', '280', '370'};
            app.CoefficientedisnervamentoDropDown.ValueChangedFcn = createCallbackFcn(app, @CoefficientedisnervamentoDropDownValueChanged, true);
            app.CoefficientedisnervamentoDropDown.Position = [568 264 100 22];
            app.CoefficientedisnervamentoDropDown.Value = '300';

            % Create CoefficienteSnervamentoLabel
            app.CoefficienteSnervamentoLabel = uilabel(app.UIFigure);
            app.CoefficienteSnervamentoLabel.HorizontalAlignment = 'center';
            app.CoefficienteSnervamentoLabel.Position = [585 242 65 22];
            app.CoefficienteSnervamentoLabel.Text = '300';

            % Create sigmanormalenMpaLabel
            app.sigmanormalenMpaLabel = uilabel(app.UIFigure);
            app.sigmanormalenMpaLabel.HorizontalAlignment = 'center';
            app.sigmanormalenMpaLabel.Position = [89 34 148 22];
            app.sigmanormalenMpaLabel.Text = 'sigma normale -σn- (Mpa) ';

            % Create sigmanormalenMpaEditField
            app.sigmanormalenMpaEditField = uieditfield(app.UIFigure, 'numeric');
            app.sigmanormalenMpaEditField.ValueDisplayFormat = '%11.5g';
            app.sigmanormalenMpaEditField.Editable = 'off';
            app.sigmanormalenMpaEditField.HorizontalAlignment = 'center';
            app.sigmanormalenMpaEditField.Position = [252 34 100 22];

            % Create sigmaflessionalefMpaEditFieldLabel
            app.sigmaflessionalefMpaEditFieldLabel = uilabel(app.UIFigure);
            app.sigmaflessionalefMpaEditFieldLabel.HorizontalAlignment = 'center';
            app.sigmaflessionalefMpaEditFieldLabel.Position = [80 73 158 22];
            app.sigmaflessionalefMpaEditFieldLabel.Text = 'sigma flessionale -σf- (Mpa) ';

            % Create sigmaflessionalefMpaEditField
            app.sigmaflessionalefMpaEditField = uieditfield(app.UIFigure, 'numeric');
            app.sigmaflessionalefMpaEditField.ValueDisplayFormat = '%11.5g';
            app.sigmaflessionalefMpaEditField.Editable = 'off';
            app.sigmaflessionalefMpaEditField.HorizontalAlignment = 'center';
            app.sigmaflessionalefMpaEditField.Position = [253 73 100 22];

            % Create sigmatotaletotMpaEditFieldLabel
            app.sigmatotaletotMpaEditFieldLabel = uilabel(app.UIFigure);
            app.sigmatotaletotMpaEditFieldLabel.HorizontalAlignment = 'center';
            app.sigmatotaletotMpaEditFieldLabel.Position = [413 107 140 22];
            app.sigmatotaletotMpaEditFieldLabel.Text = 'sigma totale -σtot- (Mpa) ';

            % Create sigmatotaletotMpaEditField
            app.sigmatotaletotMpaEditField = uieditfield(app.UIFigure, 'numeric');
            app.sigmatotaletotMpaEditField.ValueDisplayFormat = '%11.5g';
            app.sigmatotaletotMpaEditField.Editable = 'off';
            app.sigmatotaletotMpaEditField.HorizontalAlignment = 'center';
            app.sigmatotaletotMpaEditField.Position = [568 107 100 22];

            % Create coefficientedisicurezzanEditFieldLabel
            app.coefficientedisicurezzanEditFieldLabel = uilabel(app.UIFigure);
            app.coefficientedisicurezzanEditFieldLabel.HorizontalAlignment = 'center';
            app.coefficientedisicurezzanEditFieldLabel.Position = [402 73 151 22];
            app.coefficientedisicurezzanEditFieldLabel.Text = 'coefficiente di sicurezza -n-';

            % Create coefficientedisicurezzanEditField
            app.coefficientedisicurezzanEditField = uieditfield(app.UIFigure, 'numeric');
            app.coefficientedisicurezzanEditField.ValueDisplayFormat = '%11.5g';
            app.coefficientedisicurezzanEditField.Editable = 'off';
            app.coefficientedisicurezzanEditField.HorizontalAlignment = 'center';
            app.coefficientedisicurezzanEditField.Position = [568 73 100 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = gru_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end