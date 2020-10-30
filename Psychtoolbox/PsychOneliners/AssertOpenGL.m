function AssertOpenGL
% AssertOpenGL
%
% Break and issue an error message if the installed Psychtoolbox is not
% based on OpenGL or Screen() is not working properly.
% To date there are four versions of the Psychtoolbox, each based on a
% different graphics library:
%
%  OS9: Psychtoolbox-2, based on Apple's QuickDraw.
%  Win: Psychtoolbox-2, based on Direct X and GDI.
%  Win: OpenGL for the ported OSX-Psychtoolbox, aka Psychtoolbox-3.
%  OSX: OpenGL for Psychtoolbox-3.
%  Linux: OpenGL for Psychtoolbox-3.
%
%  The Psychtoolboxes based on OpenGL are partially incompatible (see below)
%  with previous Psychtoolboxes.  A script which relies on the OpenGL
%  Psychtoolbox should call AssertOpenGL so that it will issue the
%  appropriate warning if a user tries to run it on a computer with a
%  non-OpenGL based Psychtoolbox installed.
%
%  OpenGL-based Psychtoolboxes are distinguised by the availability of these
%  functions:
%
%   Screen('Flip',...);
%   Screen('MakeTexture');
%   Screen('DrawTexture');
%
%
%  If you know you're using Psychtoolbox-3, then the most likely cause for
%  this error message is a problem in the configuration of your
%  Matlab/Octave + System setup, or in the Psychtoolbox installation.
%
%  Typically either the Screen MEX file can't be found or accessed, due to
%  some wrong Matlab/Octave path (Proper Screen file not in path), or due
%  to some permission issue (insufficient security access permissions -
%  typically found on MS-Windows systems), or the Screen MEX file can't be
%  loaded and initialized due to some missing or wrong system library on
%  your machine, e.g., the C runtime library is of an incompatible type.
%  Simply type the command "Screen" at the prompt to see if this may be an
%  issue.
%
%  In both cases, indicated by some "file not found" or "file could not by
%  accesses" or "invalid MEX file" error message, you may want to run the
%  SetupPsychtoolbox command again. This will either fix the problem for
%  you by reconfiguring Psychtoolbox, or it will provide more diagnostic
%  error and troubleshooting messages. Make also sure that you read the
%  troubleshooting tips in the "Download" and "Frequently asked questions"
%  sections of our Psychtoolbox Wiki at http://www.psychtoolbox.org
%
% See also: IsOSX, IsWin, IsLinux.

% HISTORY
% 7/10/04   awi     wrote it.
% 7/13/04   awi     Fixed documentation.
% 10/6/05   awi	    Note here cosmetic changes by dgp between 7/13/04 and 10/6/05
% 12/31/05  mk      Detection code modified to really query type of Screen command (OpenGL?)
%                   instead of OS type, as PTB-OpenGL is now available for Windows as well.
% 06/05/08  mk      Hopefully more diagnostic output message added.
% 05/25/11  mk      Update linker failure message on Octave+Windows: Don't
%                   need ARVideo libraries anymore, but instead the
%                   GStreamer runtime.
% 03/24/12  mk      Add do_braindead_shortcircuit_evaluation() to avoid
%                   warnings on Octave 3.6 and later.
% 09/05/12  mk      Disable shortcircuit operator warning.
% 05/13/13  mk      Reenable short-circuit-operator warnings for Octave, as
%                   they shouldn't be needed anymore with our fixed M-Files.
% 08/07/19  mk      Update for 3.0.16 release: GStreamer 1.4+ on Linux, on Windows
%                   GStreamer 1.16+ MSVC build is mandatory on Octave *and* Matlab.
% 10/20/20  mk      Update for 3.0.17 release: GStreamer 1.8+ on Linux, on Windows
%                   GStreamer 1.18+ MSVC build is mandatory on Octave *and* Matlab.
% 10/30/20  mk      Add ln -s symlink workaround for libdc1394.25.so instead of
%                   required libdc1394.22.so on Ubuntu 20.10+.

% We put the detection code into a try-catch-end statement: The old Screen command on windows
% doesn't have a 'Version' subfunction, so it would exit to Matlab with an error.
% We catch this error in the catch-branch and output the "non-OpenGL" error message...
try
    % Query a Screen subfunction that only exists in the new Screen command If this is not
    % OpenGL PTB,we will get thrown into the catch-branch...
    value=Screen('Preference', 'SkipSyncTests'); %#ok<NASGU>
    return;
catch %#ok<*CTCH>
    fprintf('\n\n\nA very simple test call to the Screen() MEX file failed in AssertOpenGL, indicating\n');
    fprintf('that either Screen is totally dysfunctional, or you are trying to run your script on\n');
    fprintf('a system without Psychtoolbox-3 properly installed - or not installed at all.\n\n');

    %   if IsWin
    %      le = psychlasterror;
    %      if ~isempty(strfind(le.message, 'library or dependents')) && ~isempty(strfind(le.message, 'Screen.mex'))
    %         % Likely the required GStreamer 1.16+ MSVC runtimes aren't installed yet!
    %         fprintf('The most likely cause, based on the fact you are running on Octave under Windows\n');
    %         fprintf('and given this error message: %s\n', le.message);
    %         fprintf('is that the required GStreamer runtime libraries are not yet installed on your system.\n\n');
    %         fprintf('Please type ''help GStreamer'' and read the installation instructions carefully.\n');
    %         fprintf('After this one-time setup, the Screen command should work properly.\n\n');
    %         fprintf('If this has been ruled out as a reason for failure, the following could be the case:\n\n');
    %      end
    %   end

    if IsWin
        fprintf('On Windows you *must* install the MSVC build runtime of at least GStreamer 1.18.0\n');
        fprintf('or a later version. Screen() will not work with earlier versions, without GStreamer,\n');
        fprintf('or with the MinGW variants of the GStreamer runtime!\n');
        fprintf('Read ''help GStreamer'' for more info.\n\n');
    end

    if IsLinux
        % Matlab specific troubleshooting:
        if ~IsOctave
            s = psychlasterror;
            if ~isempty(strfind(s.message, 'gzopen64'))
                fprintf('YOU SEEM TO HAVE A MATLAB INSTALLATION WITH A BROKEN/OUTDATED libz library!\n');
                fprintf('This is the most likely cause for the error. You can either:\n');
                fprintf('- Upgrade to a more recent version of Matlab in the hope that this fixes the problem.\n');
                fprintf('- Or start Matlab from the commandline with the following command sequence as a workaround:\n\n');
                fprintf('  export LD_PRELOAD=/lib/libz.so.1 ; matlab & \n\n');
                fprintf('  If /lib/libz.so.1 doesn''t exist, try other locations like /usr/lib/libz.so.1 or other names\n');
                fprintf('  like /lib/libz.so, or /usr/lib/libz.so\n');
                fprintf('- A third option is to delete the libz.so library shipped with Matlab. Move away all\n');
                fprintf('  files starting with libz.so from the folder /bin/glnx86 inside the Matlab main folder.\n');
                fprintf('  This way, the linker can''t find Matlabs broken libz anymore and will use the system\n');
                fprintf('  libz and everything will be fine.\n');
                fprintf('\n');
                error('Matlab bug -- Outdated/Defective libz installed. Follow above workarounds.');
            end

            % The Octave Screen.mex file is built to depend on the libdc1394
            % version that is installed on the build system == target
            % system, so stuff should just work(tm).
            %
            % The Matlab mex files however are built on Ubuntu 18.04 LTS
            % atm., which ships with libdc1394.so.22, and so Screen.mexa64
            % depends on exactly libdc1394.so.22. Ubuntu 20.10 and later
            % ship with libdc1394.so.25 only, so running on 20.10 will cause
            % link failure. Try to work around this by automatically
            % creating a suitable symlink from the required libdc1394.so.22
            % to the available libdc1394.so.25:
            if ~isempty(strfind(s.message, 'libdc1394.so.22')) && ~exist('/lib/x86_64-linux-gnu/libdc1394.so.22', 'file') && exist('/lib/x86_64-linux-gnu/libdc1394.so.25', 'file')
                cmd = 'sudo ln -s /lib/x86_64-linux-gnu/libdc1394.so.25 /lib/x86_64-linux-gnu/libdc1394.so.22';

                fprintf('Seems your Linux distribution may be missing a suitable and functional libdc1394.so.22 library.\n');
                fprintf('We probably can fix this problem by creating a symlink from the required libdc1394.so.22 to\n');
                fprintf('the available libdc1394.so.25 by executing the following command as system administrator:\n\n');
                fprintf('Command to execute: ''%s''\n\n', cmd);
                fprintf('This will require you to enter your admin (sudo) password if you are a system administrator. Or you\n');
                fprintf('can ask your system administrator to execute the above ''Command to execute'' inside a terminal window\n');
                fprintf('and then just press enter when asked here for a sudo password.\n');
                fprintf('Your choice. Will now call above command, which will prompt for the password...\n\n');
                [rc, msg] = system(cmd, '-echo');
                if (rc == 0) && exist('/lib/x86_64-linux-gnu/libdc1394.so.22', 'file')
                    fprintf('It worked! Retrying if Screen() now works...\n');
                else
                    fprintf('Failed or aborted with error: %s\n', msg);
                    fprintf('Will retry Screen() anyway, maybe you fixed it manually in the meantime...\n');
                end

                try
                    value = Screen('Preference', 'SkipSyncTests'); %#ok<NASGU>
                    fprintf('Success! We can carry on as usual, thank you for your cooperation. Case closed! :)\n\n\n');
                    psychlasterror('reset');
                    return;
                catch
                    fprintf('This still does not work for some reason. Guess this will need help from a human...\n');
                end
            else
                fprintf('The library seems to exist in a suitable version, but something related to that library\n');
                fprintf('is borked. This needs some human help from a capable human brain, sorry.\n');
            end
        end

        fprintf('\n');
        fprintf('Screen() on GNU/Linux needs the following 3rd party libraries\n');
        fprintf('to function correctly. If you get "Invalid MEX file errors",\n');
        fprintf('or similar fatal error messages, check if these are installed on your\n');
        fprintf('system and if they are missing, install them via your system specific\n');
        fprintf('software management tools (e.g., apt install on Debian or Ubuntu):\n');
        fprintf('\n');
        fprintf('* GStreamer multimedia framework: At least version 1.8.0 of the core runtime and the gstreamer-base plugins.\n');
        fprintf('  For optimal performance and the full set of features, use the latest available versions. E.g., for HDR playback\n');
        fprintf('  GStreamer 1.18 would be needed. You may need to install additional packages to play back all common audio and\n');
        fprintf('  video file formats. See "help GStreamer" for more info.\n\n');
        fprintf('* libusb-1.0 USB low-level access library.\n\n');
        fprintf('* libdc1394 IEEE-1394 Firewire and USB-Vision IIDC video capture library.\n');
        fprintf('\n\n');
    end

    % Tried to execute old Screen command of old Win-PTB or MacOS9-PTB. This will tell user about non-OpenGL PTB.
    fprintf('Screen() does not work. Read all preceeding and following output as well as "help AssertOpenGL" for more info.\n');
    fprintf('A first diagnostic test would be to simply type ''Screen'' in your Matlab/Octave console and check what its output is.\n');
    fprintf('\n\nThe returned error message by Matlab/Octave was:\n');
    ple;
    error('Problems detected in call to AssertOpenGL;');
end
