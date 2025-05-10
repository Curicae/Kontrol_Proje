% Configuration file for API keys and settings

% Create configuration structure
configuration = struct();

% API Keys
configuration.google_maps_api_key = 'YOUR_GOOGLE_MAPS_API_KEY';
configuration.tomtom_api_key = 'YOUR_TOMTOM_API_KEY';

% Intersection Location (example coordinates)
configuration.intersection_location = struct(...
    'lat', 41.0370, ...  % Taksim Meydanı örneği
    'long', 28.9850 ...
);

% API Settings
configuration.api_update_interval = 300; % 5 minutes in seconds
configuration.use_osm = false;    % Use OpenStreetMap API
configuration.use_tomtom = false; % Use TomTom API
configuration.use_overpass = true; % Use Overpass API (free, no API key required)
configuration.overpass_radius = 500; % Search radius in meters around intersection

% Save configuration
config = configuration;
save('config.mat', 'config');

% Display the selected intersection
fprintf('Selected intersection coordinates:\n');
fprintf('Latitude: %.4f\n', config.intersection_location.lat);
fprintf('Longitude: %.4f\n', config.intersection_location.long);
fprintf('\nTo change the intersection location, edit the coordinates in this file.\n');