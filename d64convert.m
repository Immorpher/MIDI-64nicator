function midi = d64convert(midi,SwapOffOns,InsertMetaTimes,StripInfo,SetZeroRunMode,AddMissingTempo,ReChannel,TruncateEnd,NonLooping)
% midi = matlab struct format of midi to be transformed and spit back out

% Required Processing -----------------------------------------------------
% SwapOffOns = Set to 1 to enable note off to on switching
% InsertMetaTimes = Set to 1 to insert sequencer loop events
% StripInfo = Set to 1 to strip header and track info
% SetZeroRunMode = Set to 1 to set running modes to zero
% AddMissingTempo = Set to 1 to add tempo if none exists (120 bpm)

% Optional Processing -----------------------------------------------------
% ReChannel = Set to 1 to reorganize channels to avoid potential glitches
% TruncateEnd = Set to 1 to move track end to last event, helps for loop points
% NonLooping = Set to 1 to prevent track from looping like title sequence

%% Track processing
masterfields = fieldnames(midi); % Get the structure field names from readmidi input
midi = struct2cell(midi); % convert to cell array for processing

tracks = cell2mat(midi(3)); % Cell array 3 are where the notes are, so lets dig in
trackdim = length(tracks); % Get the number of tracks
tracklengths = zeros(trackdim,1); % placeholder for total track lengths for metatimes
beginpadding = zeros(trackdim,1); % placeholder for beginning metatime padding
tempocount = 0; % Place holder for tempo event counting if needed

for i=1:trackdim % dig into each track
    trackfields = fieldnames(tracks(i)); % Get current track field name, basically just says messages
    trackcell = struct2cell(tracks(i)); % Get the current track into cell
    trackcell = cell2mat(trackcell(1)); % Convert cells to a searchable matrix
    eventdim = length(trackcell); % How many events to filter

    if TruncateEnd == 1 % Move track end to last event, helps for loop points
            eventfields = fieldnames(trackcell(eventdim)); % Get ending track field name, basically just says messages
            eventcell = struct2cell(trackcell(eventdim)); % Get ending event into cell
            eventcell(2) = mat2cell(0,1); % Set delta time to 0
            trackcell(eventdim) = cell2struct(eventcell, eventfields,1); % Put ending event back into structure
    end

    if InsertMetaTimes == 1 || NonLooping == 1 % If 1 calculate times to insert meta events and strip any if needed
        j = 1; % initialize j counter
        k = 0; % to check first meta event
        while j <= eventdim % dig into each event (such as notes)
            eventfields = fieldnames(trackcell(j)); % Get current track field name, basically just says messages
            eventcell = struct2cell(trackcell(j)); % Get current event into cell
            
            if cell2mat(eventcell(4)) == 127 % Strip any existing meta fields 
                if k == 0 % check if initial meta time has padding
                    k = 1; % ignore everything after first event
                    beginpadding(i) = cell2mat(eventcell(2)); % store its padding
                end
                
                trackcell(j) = []; % erase it
                j = j - 1; % decrement j
                eventdim = eventdim - 1; % adjust for new dimension
            else % add up its time!
                tracklengths(i) = tracklengths(i) + cell2mat(eventcell(2)); % add up delta times
            end
            
            j = j + 1; % increment j
        end % end event loop
        
        tracklengths(i) = tracklengths(i) + beginpadding(i); % include any beginning pads which may have been stipped
    end

    if AddMissingTempo == 1 && tempocount == 0 % If 1 check for tempo events
        for j=1:eventdim % dig into each event (such as notes)
            eventfields = fieldnames(trackcell(j)); % Get current track field name, basically just says messages
            eventcell = struct2cell(trackcell(j)); % Get current event into cell

            if cell2mat(eventcell(4)) == 81 % Check if tempo exists
                tempocount = 1; % Increase counter
            end
        end % end event loop
    end
    
    
    if SetZeroRunMode == 1 % If 1 set all status modes to 0
        for j=1:eventdim % dig into each event (such as notes)
            eventfields = fieldnames(trackcell(j)); % Get current track field name, basically just says messages
            eventcell = struct2cell(trackcell(j)); % Get current event into cell
            eventcell(1) = mat2cell(0,1); % Swap runnding status it to 0
            trackcell(j) = cell2struct(eventcell, eventfields,1); % Put event back into structure
        end % end event loop
    end
    
    if SwapOffOns == 1 % If 1 swap note off events to on with 0 velocity
        for j=1:eventdim % dig into each event (such as notes)
            eventfields = fieldnames(trackcell(j)); % Get current track field name, basically just says messages
            eventcell = struct2cell(trackcell(j)); % Get current event into cell

            % Swap note offs into note ons with 0 velocity
            if cell2mat(eventcell(4)) == 128 % Check if type is note off
                eventcell(4) = mat2cell(144,1); % Swap it into note on
                eventdata = cell2mat(eventcell(5)); % Get note and velocity data
                eventdata(2) = 0; % Set velocity to 0
                eventcell(5) = mat2cell(eventdata,2); % Store 0 velocity back into event
            end

            trackcell(j) = cell2struct(eventcell, eventfields,1); % Put event back into structure
        end % end event loop
    end
    

    if StripInfo == 1 % If 1 strip extra info from track
        j = 1; % initialize j
        while j <= eventdim % dig into each event (such as instrument definitions)
            eventfields = fieldnames(trackcell(j)); % Get current track field name, basically just says messages
            eventcell = struct2cell(trackcell(j)); % Get current event into cell

            % Swap note offs into note ons with 0 velocity
            if cell2mat(eventcell(4)) == 1 || cell2mat(eventcell(4)) == 2 || cell2mat(eventcell(4)) == 3 || cell2mat(eventcell(4)) == 4 % Check if info event is defined then delete it
                eventdim = eventdim - 1; % new event dimension size due to deletion
                trackcell(j) = []; % delete cell

                j = j - 1; % correct for deletion
            end
            j = j + 1; % increment j
            
        end % end event loop        
    end

    if ReChannel == 1 % If 1 reorganize channels and events
        BlankEvents = [47,81,88,89,127]; % Midi events which get blanked
        for j=1:eventdim % dig into each event
            eventfields = fieldnames(trackcell(j)); % Get current track field name, basically just says messages
            eventcell = struct2cell(trackcell(j)); % Get current event into cell

            % Swap blank channels for certain events
            if any(cell2mat(eventcell(4)) == BlankEvents)
                eventcell(6) = mat2cell([],0); % Swap it to blank
            else % for the rest swap it to the current channel
                eventcell(6) = mat2cell(i-1,1); % Swap it to current order
            end

            trackcell(j) = cell2struct(eventcell, eventfields,1); % Put event back into structure
        end % end event loop
    end
    
    trackcell = mat2cell(trackcell,1); % Get it back into cell format
    tracks(i) = cell2struct(trackcell,trackfields,1); % Put it back into its structure
    
end % end track loop

if AddMissingTempo == 1 && tempocount == 0 % If conditions are met, add the missing tempo (120 assuming)
    trackfields = fieldnames(tracks(1)); % Get current track field name, basically just says messages
    trackcell = struct2cell(tracks(1)); % Get the current track into cell
    trackcell = cell2mat(trackcell(1)); % Convert cells to a searchable matrix
    eventdim = length(trackcell); % How many events to filter        
    endingcell = struct2cell(trackcell(eventdim)); % Get end of track event
    eventfields = fieldnames(trackcell(eventdim)); % Get event fields

    % insert beginning tempo
    metabeg = endingcell; % use ending cell as placeholder for the tempo event
    metabeg(1) = mat2cell(0,1); % used running mode
    metabeg(2) = mat2cell(0,1); % delta time to fill in ending gap
    metabeg(3) = mat2cell(0,1); % midimeta
    metabeg(4) = mat2cell(81,1); % type
    metabeg(5) = mat2cell([7;161;32],3); % data
    trackcell = [cell2struct(metabeg,eventfields,1) trackcell]; % insert beginning meta event

    trackcell = mat2cell(trackcell,1); % Get track back into cell format
    tracks(1) = cell2struct(trackcell,trackfields,1); % Put it back into its structure
end

if InsertMetaTimes == 1 && NonLooping ~= 1 % If 1 insert meta events
    for i=1:trackdim % dig into each track
        trackfields = fieldnames(tracks(i)); % Get current track field name, basically just says messages
        trackcell = struct2cell(tracks(i)); % Get the current track into cell
        trackcell = cell2mat(trackcell(1)); % Convert cells to a searchable matrix
        eventdim = length(trackcell); % How many events to filter        
        endingcell = struct2cell(trackcell(eventdim)); % Get end of track event
        eventfields = fieldnames(trackcell(eventdim)); % Get event fields

        % insert ending meta event
        metaend = endingcell; % use ending cell as placeholder for the ending meta event
        metaend(1) = mat2cell(0,1); % used running mode
        metaend(2) = mat2cell(max(tracklengths(:)) - tracklengths(i),1); % delta time to fill in ending gap
        metaend(3) = mat2cell(0,1); % midimeta
        metaend(4) = mat2cell(127,1); % type
        metaend(5) = mat2cell([0;32;0;0],4); % data
        trackcell(eventdim) = cell2struct(metaend,eventfields,1); % insert ending meta event
        trackcell(eventdim+1) = cell2struct(endingcell,eventfields,1); % insert end of track event

        firstnote = eventdim; % Place meta event before end if no notes are found
        j = 1; % initialize j
        while j <= eventdim % find first note to unsert beginning meta
            eventfields = fieldnames(trackcell(j)); % Get current track field name, basically just says messages
            eventcell = struct2cell(trackcell(j)); % Get current event into cell

            % Swap note offs into note ons with 0 velocity
            if cell2mat(eventcell(4)) == 144 % Check if type is note off
               firstnote = j; % first note position
               j = eventdim; % stop while loop
            end
             j = j + 1; % increment counter
        end % end event loop

        % insert beginning meta event
        metabeg = endingcell; % use ending cell as placeholder for the ending meta event
        metabeg(1) = mat2cell(0,1); % used running mode
        metabeg(2) = mat2cell(beginpadding(i),1); % delta time to fill in ending gap
        metabeg(3) = mat2cell(0,1); % midimeta
        metabeg(4) = mat2cell(127,1); % type
        metabeg(5) = mat2cell([0;35],2); % data
        trackcell = [trackcell(1:firstnote-1) cell2struct(metabeg,eventfields,1) trackcell(firstnote:end)]; % insert beginning meta event

        trackcell = mat2cell(trackcell,1); % Get track back into cell format
        tracks(i) = cell2struct(trackcell,trackfields,1); % Put it back into its structure

    end % end track loop
end

if NonLooping == 1 % If 1 check if non looping events are needed as spacers
    for i=1:trackdim % dig into each track
        if beginpadding(i) ~= 0 % Only insert initial meta events as spacers
            trackfields = fieldnames(tracks(i)); % Get current track field name, basically just says messages
            trackcell = struct2cell(tracks(i)); % Get the current track into cell
            trackcell = cell2mat(trackcell(1)); % Convert cells to a searchable matrix
            eventdim = length(trackcell); % How many events to filter        
            endingcell = struct2cell(trackcell(eventdim)); % Get end of track event
            eventfields = fieldnames(trackcell(eventdim)); % Get event fields

            firstnote = eventdim; % Place meta event before end if no notes are found
            j = 1; % initialize j
            while j <= eventdim % find first note to unsert beginning meta
                eventfields = fieldnames(trackcell(j)); % Get current track field name, basically just says messages
                eventcell = struct2cell(trackcell(j)); % Get current event into cell

                % Swap note offs into note ons with 0 velocity
                if cell2mat(eventcell(4)) == 144 % Check if type is note off
                   firstnote = j; % first note position
                   j = eventdim; % stop while loop
                end
                 j = j + 1; % increment counter
            end % end event loop

            % insert beginning meta event
            metabeg = endingcell; % use ending cell as placeholder for the ending meta event
            metabeg(1) = mat2cell(0,1); % used running mode
            metabeg(2) = mat2cell(beginpadding(i),1); % delta time to fill in ending gap
            metabeg(3) = mat2cell(0,1); % midimeta
            metabeg(4) = mat2cell(127,1); % type
            metabeg(5) = mat2cell([0;35],2); % data
            trackcell = [trackcell(1:firstnote-1) cell2struct(metabeg,eventfields,1) trackcell(firstnote:end)]; % insert beginning meta event

            trackcell = mat2cell(trackcell,1); % Get track back into cell format
            tracks(i) = cell2struct(trackcell,trackfields,1); % Put it back into its structure
        end % end spacer statement
    end % end track loop
end

midi(3) = mat2cell(tracks,1); % Get the tracks back into the midi file
midi = cell2struct(midi, masterfields, 1); % go back to structure for writemidi output

end