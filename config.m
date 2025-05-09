% Configuration file for API keys and settings

% API Keys
config.google_maps_api_key = 'YOUR_GOOGLE_MAPS_API_KEY';
config.tomtom_api_key = 'YOUR_TOMTOM_API_KEY';

% Intersection Location (example coordinates)
config.intersection_location = struct(...
    'lat', 41.0370, ...  % Taksim Meydanı örneği
    'long', 28.9850 ...
);

% API Settings
config.api_update_interval = 300; % 5 minutes in seconds
config.use_osm = true;    % Use OpenStreetMap API

% Save configuration
save('config.mat', 'config');

% Display the selected intersection
fprintf('Selected intersection coordinates:\n');
fprintf('Latitude: %.4f\n', config.intersection_location.lat);
fprintf('Longitude: %.4f\n', config.intersection_location.long);
fprintf('\nTo change the intersection location, edit the coordinates in this file.\n'); 