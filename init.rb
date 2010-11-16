# RADAR: The order makes a difference, and globbing Dir produces different results on different machines.
# We can .sort the glob, but still the order would be wrong, and we'd need to have repeated requires in
# Individual files. Michael and I think it's easier to statically call them all in one place in the right order.

require 'dirge' # TODO inclide into gem dependencies

require ~'lib/s_data'
require ~'lib/s_data/exceptions'
require ~'lib/s_data/formatting.rb'
require ~'lib/s_data/collection/pagination'
require ~'lib/s_data/collection/collection'
require ~'lib/s_data/collection/feed'
require ~'lib/s_data/collection/scope'
require ~'lib/s_data/controller_mixin/s_data_instance.rb'
require ~'lib/s_data/controller_mixin/actions.rb'
require ~'lib/s_data/atom_extensions/nodes/digest.rb'
require ~'lib/s_data/atom_extensions/nodes/payload.rb'
require ~'lib/s_data/atom_extensions/nodes/sync_state.rb'
require ~'lib/s_data/payload.rb'
require ~'lib/s_data/atom_extensions/content_mixin.rb'
require ~'lib/s_data/atom_extensions/entry_mixin.rb'
require ~'lib/s_data/namespace_definitions.rb'
require ~'lib/s_data/predicate.rb'
require ~'lib/s_data/trait.rb'
require ~'lib/s_data/sync/resource_mixin.rb'
require ~'lib/s_data/virtual_base.rb'
require ~'lib/s_data/resource/class_methods'
require ~'lib/s_data/resource/to_atom'
require ~'lib/s_data/resource/instance_methods'
require ~'lib/s_data/resource/resource_identity'
require ~'lib/s_data/resource/uuid.rb'
require ~'lib/s_data/resource/payload_map/payload_map_hash.rb'
require ~'lib/s_data/resource/payload_map/payload_map.rb'
require ~'lib/s_data/resource/base'
require ~'lib/s_data/sync/actions.rb'
require ~'lib/s_data/conditions_builder.rb'
require ~'lib/s_data/diagnosis/diagnosis.rb'
require ~'lib/s_data/diagnosis/application_controller_mixin.rb'
require ~'lib/s_data/diagnosis/diagnosis_mapper.rb'
require ~'lib/s_data/application/old_dsl_support'
require ~'lib/s_data/application/resource_from_params'
require ~'lib/s_data/application/atom_entry_recognition'
require ~'lib/s_data/application/auth'
require ~'lib/s_data/application/error_handling'
require ~'lib/s_data/application/logging'
require ~'lib/s_data/application/resource_route_mapper'
