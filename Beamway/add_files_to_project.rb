#!/usr/bin/env ruby
require 'xcodeproj'

project_path = '/Users/hades/Desktop/Code/12/1227-1/git sdk/Beamway/Beamway/Beamway.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'Beamway' }

# Get the Beamway group
beamway_group = project.main_group.find_subpath('Beamway', false)

# All new Swift files to add (relative to Beamway folder)
new_files = [
  # Core
  'Core/Constants/GameplayConstants.swift',
  'Core/Foundation/CoordinatorBase.swift',
  'Core/Foundation/ApplicationEnvironment.swift',
  'Core/Extensions/UIViewExtensions.swift',
  'Core/Protocols/ViewComponentProtocols.swift',
  'Core/Protocols/GameplayProtocols.swift',

  # Data
  'Data/Repository/SessionRecordRepository.swift',
  'Data/Models/SessionResultDataModel.swift',

  # Managers
  'Managers/Animation/MotionEffectsCoordinator.swift',
  'Managers/Theme/VisualThemeConfiguration.swift',
  'Managers/Haptic/TouchFeedbackController.swift',

  # Services
  'Services/Spawning/ProjectileSpawningController.swift',
  'Services/GameEngine/GameplayOrchestrator.swift',
  'Services/Scoring/ScoringProcessingEngine.swift',
  'Services/Collision/CollisionProcessingEngine.swift',

  # ViewModels
  'ViewModels/GameSessionViewModel.swift',

  # MainGame
  'MainGame/UI/BackgroundSceneRenderer.swift',
  'MainGame/UI/GameOverlayPresentationController.swift',
  'MainGame/UI/PlayZoneContainerView.swift',
  'MainGame/UI/GameControlButtonsManager.swift',
  'MainGame/Configurators/PlayZoneConfigurator.swift',
  'MainGame/Configurators/BackdropConfigurator.swift',
  'MainGame/Configurators/FooterControlsConfigurator.swift',
  'MainGame/GameLogic/ProjectileEntityController.swift',
  'MainGame/GameLogic/BlockEntityController.swift',
  'MainGame/Controllers/GameLogicController.swift',
  'MainGame/Controllers/GameVisualEffectsCoordinator.swift',
  'MainGame/Controllers/CollisionDetectionEngine.swift',
  'MainGame/Controllers/PlaySessionController.swift',
  'MainGame/Controllers/GameOverPresentationController.swift',
  'MainGame/Controllers/PauseOverlayController.swift',
  'MainGame/Controllers/GameHUDManager.swift',
  'MainGame/HUD/SessionHeadsUpDisplayManager.swift',
  'MainGame/Session/GameSessionCoordinator.swift',

  # GameRecord
  'GameRecord/Configurators/RecordsScreenConfigurators.swift',
  'GameRecord/Components/RecordsUIComponents.swift',
  'GameRecord/Components/MatchHistoryItem.swift',
  'GameRecord/Controllers/RecordsAnimationController.swift',
  'GameRecord/Controllers/MatchHistoriesController.swift',
  'GameRecord/Services/RecordsDataManager.swift',

  # ModeSelection
  'ModeSelection/Configurators/ModeSelectionConfigurators.swift',
  'ModeSelection/Components/ModeSelectionUIComponents.swift',
  'ModeSelection/Components/CategoryTilePanel.swift',
  'ModeSelection/Controllers/ModeSelectionAnimationController.swift',
  'ModeSelection/Controllers/CategoryPickerController.swift',

  # Welcome
  'Welcome/Configurators/WelcomeScreenConfigurators.swift',
  'Welcome/Components/WelcomeUIComponents.swift',
  'Welcome/Controllers/GreetingPanelController.swift',
  'Welcome/Services/WelcomeScreenAnimationCoordinator.swift',
  'Welcome/Services/WelcomeMetricsDataProvider.swift',

  # GameRules
  'GameRules/Configurators/RulesScreenConfigurators.swift',
  'GameRules/Builders/RulesContentBuilder.swift',
  'GameRules/Components/RulesUIComponents.swift',
  'GameRules/Controllers/GuidelinesDisplayController.swift',
  'GameRules/Controllers/RulesAnimationController.swift',
]

beamway_path = '/Users/hades/Desktop/Code/12/1227-1/git sdk/Beamway/Beamway/Beamway'

def find_or_create_group(parent_group, path_components)
  return parent_group if path_components.empty?

  name = path_components.first
  group = parent_group.children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && c.name == name }

  if group.nil?
    group = parent_group.new_group(name, name)
  end

  find_or_create_group(group, path_components[1..-1])
end

new_files.each do |relative_path|
  full_path = File.join(beamway_path, relative_path)

  # Skip if file doesn't exist
  unless File.exist?(full_path)
    puts "Warning: File not found: #{full_path}"
    next
  end

  # Get directory components
  dir_components = File.dirname(relative_path).split('/')

  # Find or create the parent group
  parent_group = find_or_create_group(beamway_group, dir_components)

  # Check if file already exists in group
  file_name = File.basename(relative_path)
  existing = parent_group.files.find { |f| f.name == file_name || f.path == file_name }

  if existing
    puts "Skipping (already exists): #{relative_path}"
    next
  end

  # Add file reference
  file_ref = parent_group.new_file(file_name)

  # Add to target's source build phase
  target.source_build_phase.add_file_reference(file_ref)

  puts "Added: #{relative_path}"
end

project.save

puts "\nProject updated successfully!"
