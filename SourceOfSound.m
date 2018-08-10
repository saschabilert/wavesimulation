classdef SourceOfSound < handle
%SOURCEOFSOUND caluculates and stores the mathematical part of the project
%call contains following properties:
%
%   - storing the data of a single speaker
%   - calulates the data matrix
%   - methods to set variable data
%
% @autor Eike Claaßen, Jan-Michel Grüttgen, Sascha Bilert
% @version 1.0 (June 2015)
% 
% Copyright © 2015 Eike Claaßen, Jan-Michel Grüttgen, Sascha Bilert
% Using the MIT License

    properties
        Position;
        RadiiMatrix;
        SpeedOfSound;
        WaveVector;
        Amplitude;
        AmplitudesMatrix;
        Frequency;
        AngularFrequency;
        Phase;
        Damping;
        Resolution;
    end
    
    
    methods
        
        function obj = SourceOfSound(position, amplitude, frequency, phase, damping, speedOfSound, resolution)
            obj.Position = position;
            obj.Amplitude = amplitude;
            obj.Frequency = frequency;
            obj.Phase = phase;
            obj.Damping = damping;
            obj.SpeedOfSound = speedOfSound;
            obj.Resolution = resolution;
            obj.setPosition(position);
            obj.setSpeedOfSound(speedOfSound);
            obj.setAmplitude(amplitude);
            obj.setFrequency(frequency);
            obj.setPhase(phase);
            obj.setDamping(damping);
            obj.setResolution(resolution);
        end
        
        
        function setPosition(obj, position)
            obj.Position = position;
            [X,Y] = meshgrid(-10*pi:obj.Resolution:10*pi);
            obj.RadiiMatrix = sqrt((X-obj.Position(1)).^2 + (Y-obj.Position(2)).^2);
            obj.setAmplitude(obj.Amplitude);
        end
        
        function setSpeedOfSound(obj, speedOfSound)
            obj.SpeedOfSound = speedOfSound;
            obj.WaveVector = obj.AngularFrequency/obj.SpeedOfSound;
        end
        
        function setAmplitude(obj, amplitude)
            obj.Amplitude = amplitude;
            obj.AmplitudesMatrix = obj.Amplitude./sqrt(obj.RadiiMatrix);
        end
        
        function setFrequency(obj, frequency)
            obj.Frequency = frequency;
            obj.AngularFrequency = 2*pi*obj.Frequency;
            obj.WaveVector = obj.AngularFrequency/obj.SpeedOfSound;
        end
        
        function setPhase(obj, phase)
            obj.Phase = phase;
        end
        
        function setDamping(obj, damping)
            obj.Damping = damping;
        end
        
        function setResolution(obj, resolution)
            obj.Resolution = resolution;
            obj.setPosition(obj.Position);
        end
        
        function colorMap = getColorMap(obj, t)
            colorMap = exp(-obj.Damping.*obj.RadiiMatrix).*obj.AmplitudesMatrix.*cos(obj.AngularFrequency*t-obj.WaveVector*1000*obj.RadiiMatrix+obj.Phase);
        end
    end
    
end

