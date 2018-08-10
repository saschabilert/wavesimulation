classdef WaveGUI < handle
%WAVEGUI is the main class of our Project. Instances of this
%class contain the following properties:
%
%   - GUI 
%   - Timer
%   - Handles of UIControls
%   - Callback-Functions of UIControls
%
% @autor Eike Claa�en, Jan-Michel Gr�ttgen, Sascha Bilert
% @version 1.0 (June 2015)
% 
% Copyright � 2015 Eike Claa�en, Jan-Michel Gr�ttgen, Sascha Bilert
% Using the MIT License

    properties 
        Handles;
        Timer;
        Speakers;
        Picture;
        CurrentPosition;
        DefaultAmplitude = 5;
        DefaultFrequency = 0.15;
        DefaultPhase = 0;
        DefaultDamping = 0;
        SpeedOfSound = 343;
        Resolution = pi/28;
        Quality;
        PlotPosition = [1 1];
    end
    
    methods
        
        %Constructor creates a new WaveGUI object (opens the GUI).
        function obj = WaveGUI
            obj.Picture = flipud(imread('wir.jpg'));
            obj.Timer = timer('Period',0.06,...
                              'TimerFcn',@(handle,eventdata)obj.runAnimation,...
                              'ExecutionMode','FixedRate');
            obj.openGUI;  
        end
    end
        
    methods (Access = private)
        
        %Function to create all the parts of our GUI
        function openGUI(obj)
            
            hfig = figure('Name','Wavefield Simulation',...
                          'NumberTitle','off',... 
                          'Position',[100 60 1024 608],... 
                          'ToolBar','none',...
                          'MenuBar','none',...
                          'Resize','off',...
                          'CloseRequestFcn',@(handle,eventdata)obj.closeGUI);
            colormap gray;
                      
            hPlotFig = figure('Name','Lineplot',...
                           'Visible','off',...
                           'WindowStyle','normal',...
                           'NumberTitle','off',... 
                           'Position',[500 300 840 330],... 
                           'ToolBar','none',...
                           'MenuBar','none',...
                           'Resize','off',...
                           'CloseRequestFcn',@(handle,eventdata)obj.closeLinePlot);
                       
            hPlotAxes = axes('Parent',hPlotFig,...
                             'Units','pixels',...
                             'Visible','on',...
                             'Position',[25 25 800 290],...
                             ...'XTick',[],...
                             ...'YTick',[],...
                             'XGrid','on',...
                             'YGrid','on',...
                             ...'XLim',[0 1000],...
                             ...'YLim',[-2 2],...
                             'ClippingStyle','rectangle');
                       
            hPlot = animatedline;
            hPlot.MaximumNumPoints = 100;
           
            hStart = uicontrol('Parent',hfig,...
                               'String','Start',...
                               'Style','Pushbutton',...
                               'Enable','off',...
                               'Position',[20 70 100 30],...
                               'FontSize',10,...
                               'Tooltip','Start the simulation',...
                               'Callback',@(handle,eventdata)obj.startAnimation); 
 
            hClear = uicontrol('Parent',hfig,...
                               'String','Clear',...
                               'Style','Pushbutton',...
                               'Enable','off',...
                               'Position',[130 70 100 30],...
                               'FontSize',10,...
                               'Tooltip','Deletes all sources',...
                               'Callback',@(handle,eventdata)obj.clearAnimation);
                                                   
            hMedium = uicontrol('Parent',hfig,...
                                'Style','Popupmenu',...
                                'Position',[20 20 100 35],...
                                'String',{'Air','Helium','Water'},...
                                'Tooltip','Choose a medium',...
                                'FontSize',10,...
                                'Callback',@(handle,eventdata)obj.setMedium);
                            
                            
            hQuality = uicontrol('Parent',hfig,...
                                 'Style','popupmenu',...
                                 'String',{'High','Low'},...
                                 'Position',[130 20 100 35],...
                                 'FontSize',10,...
                                 'Tooltip','Set the quality of the simulation',...
                                 'Callback',@(handle,eventdata)obj.setQuality);
                             
            hSpeakerList = uicontrol('Parent',hfig,...
                                     'Style','Listbox',...
                                     'Enable','off',...
                                     'String',{},...
                                     'Position',[20 200 210 180],...
                                     'FontSize',11,...
                                     'Tooltip','List of all sources',...
                                     'Callback',@(handle,eventdata)obj.selectSpeaker);
                                 
            hLinePlot = uicontrol('Parent',hfig,...
                                  'Style','checkbox',...
                                  'String','Select a point for the line plot',...
                                  'Position',[20 160 200 20],...
                                  'FontSize',11,...
                                  'Value',0,...
                                  'Tooltip','Select a point for the line plot',...
                                  'Callback',@(handle,eventdata)obj.openLinePlot);
                                 
            hAdd = uicontrol('Parent',hfig,...
                             'Style','Pushbutton',...
                             'String','Add',...
                             'Position',[20 115 100 30],...
                             'FontSize',10,...
                             'Tooltip','Adds a sound-source to the field',...
                             'Callback',@(handle,eventdata)obj.addSpeaker);
            
            hRemove = uicontrol('Parent',hfig,...
                                'Style','Pushbutton',...
                                'String','Remove',...
                                'Enable','off',...
                                'Position',[130 115 100 30],...
                                'FontSize',10,...
                                'Tooltip','Removes the selected source',...
                                'Callback',@(handle,eventdata)obj.removeSpeaker);
                             
            hAnimationAxes = axes('Parent',hfig,...
                                  'Units','pixels',...
                                  'CLim',[-1 1],...
                                  'CLimMode','manual',...
                                  'Visible','off',...
                                  'Position',[160 -50 930 710],...
                                  'XTick',[],...
                                  'YTick',[],...
                                  'ClippingStyle','rectangle');
 
            hSetting = uipanel('Parent',hfig,...
                               'Units','pixels',... 
                               'Position',[20 390 210 200],...
                               'Title','Settings',...
                               'FontSize',12);
                         
            hSettingFrequencyText = uicontrol('Parent',hSetting,...
                                              'Style','Text',...
                                              'String','Frequency',...
                                              'Tooltip','Sets the frequency of the selected source',...
                                              'Position',[20 160 180 20]);
                         
            hSettingFrequency = uicontrol('Parent',hSetting,...
                                          'Style','Slider',...
                                          'Position',[15 140 180 20],...
                                          'Enable','off',...
                                          'Min',0,'Max',0.3,...
                                          'SliderStep',[0.01 0.1],...
                                          'Value',0.15,...
                                          'Tooltip','Sets the frequency of the selected source',...
                                          'Callback',@(handle,eventdata)obj.changeFrequency);
                                    
            hSettingAmplitudeText = uicontrol('Parent',hSetting,...
                                              'Style','Text',...
                                              'String','Amplitude',...
                                              'Tooltip','Sets the amplitude of the selected source',...
                                              'Position',[20 120 180 20]);
                                    
            hSettingAmplitude = uicontrol('Parent',hSetting,...
                                          'Style','Slider',...
                                          'Position',[15 100 180 20],...
                                          'Enable','off',...
                                          'Min',0,'Max',10,...
                                          'SliderStep',[0.01 0.1],...
                                          'Value',5,...
                                          'Tooltip','Sets the amplitude of the selected source',...
                                          'Callback',@(handle,eventdata)obj.changeAmplitude);
                                    
            hSettingPhaseText = uicontrol('Parent',hSetting,...
                                          'Style','Text',...
                                          'String','Phase',...
                                          'Tooltip','Sets the phase of the selected source',...
                                          'Position',[15 80 180 20]);
                                    
            hSettingPhase = uicontrol('Parent',hSetting,...
                                      'Style','Slider',...
                                      'Position',[15 60 180 20],...
                                      'Enable','off',...
                                      'Min',0,'Max',2*pi,...
                                      'SliderStep',[0.01 0.1],...
                                      'Value',0,...
                                      'Tooltip','Sets the phase of the selected source',...
                                      'Callback',@(handle,eventdata)obj.changePhase);
                                  
            hSettingDampingText = uicontrol('Parent',hSetting,...
                                            'Style','Text',...
                                            'String','Damping',...
                                            'Tooltip','Sets the damping of the selected source',...
                                            'Position',[15 40 180 20]);
                                  
            hSettingDamping = uicontrol('Parent',hSetting,...
                                        'Style','Slider',...
                                        'Position',[15 20 180 20],...
                                        'Enable','off',...
                                        'Min',0,'Max',1,...
                                        'SliderStep',[0.01 0.1],...
                                        'Value',0,...
                                        'Tooltip','Sets the damping of the selected source',...
                                        'Callback',@(handle,eventdata)obj.changeDamping);
                                   
            hImage = image('Parent',hAnimationAxes,...
                           'Visible','on',...
                           'XData',[-31.4 31.4],...
                           'YData',[-31.4 31.4],...
                           'CDataMapping','scaled',...
                           'CData',obj.Picture,...
                           'ButtonDownFcn',@obj.setPoint);
                        
            obj.Handles = struct('hfig',hfig,...
                                 'hPlotFig',hPlotFig,...
                                 'hPlotAxes',hPlotAxes,...
                                 'hPlot',hPlot,...
                                 'hStart',hStart,...
                                 'hClear',hClear,...
                                 'hQuality',hQuality,...
                                 'hMedium',hMedium,...
                                 'hAdd',hAdd,...
                                 'hRemove',hRemove,...
                                 'hSpeakerList',hSpeakerList,...
                                 'hLinePlot',hLinePlot,...
                                 'hAnimationAxes',hAnimationAxes,...
                                 'hSetting',hSetting,...
                                 'hImage',hImage,...
                                 'hSettingFrequencyText',hSettingFrequencyText,...
                                 'hSettingFrequency',hSettingFrequency,...
                                 'hSettingAmplitudeText',hSettingAmplitudeText,...
                                 'hSettingAmplitude',hSettingAmplitude,...
                                 'hSettingPhaseText',hSettingPhaseText,...
                                 'hSettingPhase',hSettingPhase,...
                                 'hSettingDampingText',hSettingDampingText,...
                                 'hSettingDamping',hSettingDamping);
        end
        
        %Function to inizilise the closerequest for our GUI
        function closeGUI(obj)
            obj.clearAnimation;
            delete(obj.Timer);
            if ishandle(obj.Handles.hPlotFig)
                close(obj.Handles.hPlotFig)
            end
            closereq;
        end
        
        %Function to Start our Animation
        function startAnimation(obj)
            if strcmp(obj.Timer.Running,'off')
                start(obj.Timer);
                obj.Handles.hStart.String = 'Freeze';
            elseif strcmp(obj.Timer.Running,'on')
                stop(obj.Timer);
                obj.Handles.hStart.String = 'Start';
            end
        end
  
        %Function to Clear the image and stop the Timer
        function clearAnimation(obj)
            stop(obj.Timer);
            obj.Handles.hSpeakerList.Value = 1;
            obj.Handles.hSpeakerList.String = {};
            obj.Speakers = {};
            set(obj.Handles.hImage,'CData',obj.Picture);
            obj.Handles.hStart.String = 'Start';
            obj.Handles.hStart.Enable = 'off';
            obj.Handles.hRemove.Enable = 'off';
            obj.Handles.hClear.Enable='off';
            obj.Handles.hSettingFrequency.Enable = 'off';
            obj.Handles.hSettingAmplitude.Enable = 'off';
            obj.Handles.hSettingPhase.Enable = 'off';
            obj.Handles.hSettingDamping.Enable = 'off';                
        end
        
        %Function is called by the Timer object and draws a new Waveimage
        function runAnimation(obj)
            obj.Handles.hImage.Visible = 'on';
            size = length(-10*pi:obj.Resolution:10*pi);
            sMap = zeros(size);
            for i = 1:length(obj.Speakers)
                sMap = sMap + obj.Speakers{i}.getColorMap(obj.Timer.TasksExecuted);
            end
            set(obj.Handles.hImage,'CData',sMap);
            if obj.Handles.hLinePlot.Value == 1
                addpoints(obj.Handles.hPlot,obj.Timer.TasksExecuted,sMap(obj.PlotPosition(1),obj.PlotPosition(2)));
            end
        end
  
        %Function to add new Speaker to the existing field
        function addSpeaker(obj)
            position = [(rand(1)-0.5)*10*pi (rand(1)-0.5)*10*pi];
            amplitude = obj.DefaultAmplitude;
            frequency = obj.DefaultFrequency;
            phase = obj.DefaultPhase;
            damping = obj.DefaultDamping;
            resolution = obj.Resolution;
            speedOfSound = obj.SpeedOfSound;
            obj.Speakers{length(obj.Speakers)+1} = SourceOfSound(position, amplitude, frequency, phase, damping, speedOfSound, resolution);
            obj.Speakers{length(obj.Speakers)}.setResolution(obj.Resolution);
            obj.Handles.hStart.Enable = 'on';
            obj.Handles.hSpeakerList.Enable = 'on';
            obj.Handles.hRemove.Enable = 'on';
            obj.Handles.hClear.Enable='on';
            obj.Handles.hSpeakerList.String = [obj.Handles.hSpeakerList.String; cellstr(strcat('Speaker',num2str(length(obj.Speakers))))];
            obj.Handles.hSpeakerList.Value = length(obj.Speakers);
            obj.selectSpeaker;
            if length(obj.Speakers) == 5
                warndlg('We recommend no more Speakers!','Speaker-overflow');
            end
        end
        
        %Function to remove a selected speaker
        function removeSpeaker(obj)
            speakerNr = obj.Handles.hSpeakerList.Value;
            obj.Handles.hSpeakerList.Value = 1;
            obj.Speakers = [obj.Speakers(1:speakerNr-1) obj.Speakers(speakerNr+1:end)];
            obj.Handles.hSpeakerList.String(speakerNr) = [];
            if isempty(obj.Handles.hSpeakerList.String)
                obj.clearAnimation;
            end
        end
        
        %Function to enable the Settings and to make future extensions 
        function selectSpeaker(obj)
            obj.setSetting;
        end
        
        %Function called by the selectSpeaker function to enable the uicontrols 
        function setSetting(obj)
            if ~isempty(obj.Handles.hSpeakerList.Value)
                currentSpeaker = obj.Speakers{obj.Handles.hSpeakerList.Value};
                obj.Handles.hSettingFrequency.Value = currentSpeaker.Frequency;
                obj.Handles.hSettingAmplitude.Value = currentSpeaker.Amplitude;
                obj.Handles.hSettingPhase.Value = currentSpeaker.Phase;
                obj.Handles.hSettingDamping.Value = currentSpeaker.Damping;
                obj.Handles.hSettingFrequency.Enable = 'on';
                obj.Handles.hSettingAmplitude.Enable = 'on';
                obj.Handles.hSettingPhase.Enable = 'on';
                obj.Handles.hSettingDamping.Enable = 'on';
            end
        end
        
        %Function to handles the last clicked position and pass it to the
        %setSourceOfSound and setLinePlot function
        function setPoint(obj,~,event)
            X = event.IntersectionPoint(1);
            Y = event.IntersectionPoint(2);
            obj.CurrentPosition = [X Y];
            if obj.Handles.hLinePlot.Value == 0
                obj.setSourceOfSound(obj.CurrentPosition);
            elseif obj.Handles.hLinePlot.Value == 1
                obj.setLinePlot(obj.CurrentPosition);
            end
        end
        
        %Function to place the speaker to a given position
        function setSourceOfSound(obj,position)
            if ~isempty(obj.Speakers)
                speakerNr = obj.Handles.hSpeakerList.Value;
                obj.Speakers{speakerNr}.setPosition(position);
            end
        end
        
        %Function to open the lineplot and handles the uicontrols
        function openLinePlot(obj)
            if obj.Handles.hLinePlot.Value == 1
                obj.Handles.hPlotFig.Visible = 'on';
                obj.Handles.hQuality.Enable = 'off';
            end
        end
        
        %Function to close the lineplot and handles the uicontrols
        function closeLinePlot(obj)
            obj.Handles.hLinePlot.Value = 0;
            obj.Handles.hPlotFig.Visible = 'off';
            obj.Handles.hQuality.Enable = 'on';
        end
        
        function setLinePlot(obj,position)
            x = ceil((position(1)+31.4)*(1/obj.Resolution));
            y = ceil((position(2)+31.4)*(1/obj.Resolution));
            obj.PlotPosition = [x y];
        end

        %Function to set the timerperiode and the resolution of the image
        function setQuality(obj)
            isRunning = 0;
            if strcmp(obj.Timer.Running,'on')
                isRunning = 1;
            end
            stop(obj.Timer);
            quality = obj.Handles.hQuality.String{obj.Handles.hQuality.Value};
            obj.Quality = quality;
            switch quality
                case 'High'
                    obj.Timer.Period = 0.06;
                    obj.setResolution(pi/28);
                case 'Low'
                    obj.Timer.Period = 0.06;
                    obj.setResolution(pi/8);
            end
            if isRunning
                start(obj.Timer);
            end
        end
        
        %Function to handle the different Media
        function setMedium(obj)
            medium = obj.Handles.hMedium.String{obj.Handles.hMedium.Value};
            switch medium
                case 'Air'
                    obj.SpeedOfSound = 343;
                case 'Water'
                    obj.SpeedOfSound = 1484;
                case'Helium'
                    obj.SpeedOfSound = 981;
            end            
            for i = 1:length(obj.Speakers)
                obj.Speakers{i}.setSpeedOfSound(obj.SpeedOfSound);
            end
        end
        
        %The following functions handle the slider uicontrols and 
        %allow several settings
        function changeFrequency(obj)
            frequency = obj.Handles.hSettingFrequency.Value;
            speakerNr = obj.Handles.hSpeakerList.Value;
            obj.Speakers{speakerNr}.setFrequency(frequency);
        end
        
        function changeAmplitude(obj)
            amplitude = obj.Handles.hSettingAmplitude.Value;
            speakerNr = obj.Handles.hSpeakerList.Value;
            obj.Speakers{speakerNr}.setAmplitude(amplitude);
        end
        
        function changePhase(obj)
            phase = obj.Handles.hSettingPhase.Value;
            speakerNr = obj.Handles.hSpeakerList.Value;
            obj.Speakers{speakerNr}.setPhase(phase);
        end
        
        function changeDamping(obj)
            damping = obj.Handles.hSettingDamping.Value;
            speakerNr = obj.Handles.hSpeakerList.Value;
            obj.Speakers{speakerNr}.setDamping(damping);
        end
        
        function setResolution(obj, resolution)
            obj.Resolution = resolution;
            for i = 1:length(obj.Speakers)
                obj.Speakers{i}.setResolution(resolution);
            end
        end
    end
end