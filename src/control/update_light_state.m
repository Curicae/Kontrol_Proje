function [current_light_state, phase_changed, remaining_phase_time] = update_light_state(current_light_state, time_in_current_state, green_duration_NS, green_duration_EW, yellow_light_duration, time_step_size, previous_was_NS_green)
% update_light_state - Updates the state of the traffic lights
% Inputs:
%   current_light_state - Current state ('NS_green', 'NS_yellow', 'EW_green', 'EW_yellow')
%   time_in_current_state - Time elapsed in the current state
%   green_duration_NS - Green light duration for North-South direction
%   green_duration_EW - Green light duration for East-West direction
%   yellow_light_duration - Yellow light duration
%   time_step_size - Simulation time step size
%   previous_was_NS_green - Boolean, true if the previous state was NS_green (helps determine next phase after yellow)
% Outputs:
%   current_light_state - Updated state
%   phase_changed - Boolean, true if the state just changed
%   remaining_phase_time - Time remaining in the new phase (if phase_changed is true)

phase_changed = false;
remaining_phase_time = 0;

% Determine the duration of the current state
switch current_light_state
    case 'NS_green'
        current_phase_duration = green_duration_NS;
    case 'NS_yellow'
        current_phase_duration = yellow_light_duration;
    case 'EW_green'
        current_phase_duration = green_duration_EW;
    case 'EW_yellow'
        current_phase_duration = yellow_light_duration;
    otherwise
        % Should not happen, maybe initialize to a default state
        current_light_state = 'NS_green';
        current_phase_duration = green_duration_NS;
        phase_changed = true; % Consider it a change to start correctly
        remaining_phase_time = green_duration_NS;
        return;
end

% Check if the current phase duration is over
if time_in_current_state >= current_phase_duration
    phase_changed = true;
    
    % Transition to the next state
    switch current_light_state
        case 'NS_green'
            current_light_state = 'NS_yellow';
            remaining_phase_time = yellow_light_duration;
            fprintf('  Phase change: NS Green -> NS Yellow\n');
        case 'NS_yellow'
            % After NS yellow, it transitions to EW green
            current_light_state = 'EW_green';
            remaining_phase_time = green_duration_EW; % Use the new EW green duration
            fprintf('  Phase change: NS Yellow -> EW Green\n');
        case 'EW_green'
            current_light_state = 'EW_yellow';
            remaining_phase_time = yellow_light_duration;
            fprintf('  Phase change: EW Green -> EW Yellow\n');
        case 'EW_yellow'
            % After EW yellow, it transitions to NS green
            current_light_state = 'NS_green';
            remaining_phase_time = green_duration_NS; % Use the new NS green duration
            fprintf('  Phase change: EW Yellow -> NS Green\n');
    end
end

end 