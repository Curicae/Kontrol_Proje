function [vehicle_queues, vehicles_passed] = move_vehicles(vehicle_queues, current_light_state, vehicles_per_second, time_step_size)
    % Kavşaktan geçen araçları simüle eder
    % Girdiler:
    %   vehicle_queues: Her yön için kuyrukları içeren yapı
    %   current_light_state: Mevcut trafik ışığı durumu ('NS_green' veya 'EW_green')
    %   vehicles_per_second: Saniyede geçebilecek araç sayısı
    %   time_step_size: Simülasyon zaman adımı
    % Çıktılar:
    %   vehicle_queues: Güncellenmiş araç kuyrukları
    %   vehicles_passed: Geçen araç sayısı

    vehicles_passed = 0;
    max_vehicles_this_step = round(vehicles_per_second * time_step_size);

    % Kuzey-Güney yönünü işle
    if strcmp(current_light_state, 'NS_green')
        % Kuzey kuyruğunu işle
        if ~isempty(vehicle_queues.north)
            num_to_move = min(max_vehicles_this_step, length(vehicle_queues.north));
            vehicle_queues.north(1:num_to_move) = [];
            vehicles_passed = vehicles_passed + num_to_move;
        end
        
        % Güney kuyruğunu işle
        if ~isempty(vehicle_queues.south)
            num_to_move = min(max_vehicles_this_step - vehicles_passed, length(vehicle_queues.south));
            vehicle_queues.south(1:num_to_move) = [];
            vehicles_passed = vehicles_passed + num_to_move;
        end
    end

    % Doğu-Batı yönünü işle
    if strcmp(current_light_state, 'EW_green')
        % Doğu kuyruğunu işle
        if ~isempty(vehicle_queues.east)
            num_to_move = min(max_vehicles_this_step, length(vehicle_queues.east));
            vehicle_queues.east(1:num_to_move) = [];
            vehicles_passed = vehicles_passed + num_to_move;
        end
        
        % Batı kuyruğunu işle
        if ~isempty(vehicle_queues.west)
            num_to_move = min(max_vehicles_this_step - vehicles_passed, length(vehicle_queues.west));
            vehicle_queues.west(1:num_to_move) = [];
            vehicles_passed = vehicles_passed + num_to_move;
        end
    end
end 