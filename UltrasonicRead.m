classdef UltrasonicRead < realtime.internal.SourceSampleTime ...
        & coder.ExternalDependency ...
        & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    %
    % Read the logical state of a digital input pin.
    %
    
    % Copyright 2016 The MathWorks, Inc.
    %#codegen
    %#ok<*EMCA>
    
    properties 
        EchoPinNumber = 8
        TriggerPinNumber = 11
    end
    
    methods
        % Constructor
        function obj = UltrasonicRead(varargin) 
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
        
        function set.EchoPinNumber(obj,value)
            % https://www.kernel.org/doc/Documentation/gpio/gpio-legacy.txt
            validateattributes(value,...
                {'numeric'},...
                {'real','nonnegative','integer','scalar'},...
                '', ...
                'EchoPinNumber');
            obj.EchoPinNumber = value;
        end
        
        function set.TriggerPinNumber(obj,value)
            % https://www.kernel.org/doc/Documentation/gpio/gpio-legacy.txt
            validateattributes(value,...
                {'numeric'},...
                {'real','nonnegative','integer','scalar'},...
                '', ...
                'TriggerPinNumber');
            obj.TriggerPinNumber = value;
        end
    end
    
    methods (Access=protected)
        %% Common functions
        function setupImpl(obj) %#ok<MANU>
            % Does nothing in code generation
            if ~isempty(coder.target)
                coder.cinclude('ultrasonicio_raspi.h');
                % void MW_gpioInit(const uint32_T pin, const boolean_T direction)
                coder.ceval('ultrasonicIOSetup',uint32(obj.TriggerPinNumber),uint32(obj.EchoPinNumber));
            end
        end
        
        function y = stepImpl(obj) %#ok<INUSD>
            % Implement output.
            y = 0.0;
            if ~isempty(coder.target)
                % real_T readUltrasonicDistance(uint8_T pin, UNIT_SELECTION unit)
                y = coder.ceval('readUltrasonicDistance'); %, uint32(0));
                %coder.ceval('writeTriggerPin', uint32(obj.TriggerPinNumber));
            end
        end
        
        function releaseImpl(obj) %#ok<MANU>
            if ~isempty(coder.target)
                % void MW_gpioTerminate(const uint32_T pin)
                %coder.ceval('MW_gpioTerminate',uint32(obj.PinNumber));
            end
        end
    end
    
    methods (Access=protected)
        %% Define output properties
        function num = getNumInputsImpl(~)
            num = 0;
        end
        
        function num = getNumOutputsImpl(~)
            num = 1;
        end
        
        function flag = isOutputSizeLockedImpl(~,~)
            flag = true;
        end
        
        function varargout = isOutputFixedSizeImpl(~,~)
            varargout{1} = true;
        end
        
        function flag = isOutputComplexityLockedImpl(~,~)
            flag = true;
        end
        
        function varargout = isOutputComplexImpl(~)
            varargout{1} = false;
        end
        
        function varargout = getOutputSizeImpl(~)
            varargout{1} = [1,1];
        end
        
        function varargout = getOutputDataTypeImpl(~)
            varargout{1} = 'double';
        end
        
        function icon = getIconImpl(~)
            % Define a string as the icon for the System block in Simulink.
            icon = 'Ultrasonic Read';
        end    
    end
        
    methods (Static, Access=protected)
        function simMode = getSimulateUsingImpl(~)
            simMode = 'Interpreted execution';
        end
        
        function isVisible = showSimulateUsingImpl
            isVisible = false;
        end
    end
    
    methods (Static)
        function name = getDescriptiveName()
            name = 'Ultrasonic Read';
        end
        
        function b = isSupportedContext(context)
            b = context.isCodeGenTarget('rtw');
        end
        
        function updateBuildInfo(buildInfo, context)
            if context.isCodeGenTarget('rtw')
                % Update buildInfo
                srcDir = fullfile(fileparts(mfilename('fullpath')),'src'); %#ok<NASGU>
                includeDir = fullfile(fileparts(mfilename('fullpath')),'include');
                addIncludePaths(buildInfo,includeDir);
                addIncludePaths(buildInfo,'/usr/local/include');
%                 addIncludePaths(buildInfo,'/usr/local/lib');
                % Use the following API's to add include files, sources and
                addSourceFiles(buildInfo, 'ultrasonicio_raspi.c', srcDir);
                % linker flags
                %addIncludeFiles(buildInfo,'source.h',includeDir);
                %addSourceFiles(buildInfo,'source.c',srcDir);
                %addLinkFlags(buildInfo,{'-lSource'});
                addLinkFlags(buildInfo,{'-lwiringPi'});
                %addLinkObjects(buildInfo,'sourcelib.a',srcDir);
                addCompileFlags(buildInfo,{'-lwiringPi'});
                %addDefines(buildInfo,'MY_DEFINE_1')
            end
        end
    end
end

