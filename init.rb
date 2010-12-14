# RADAR: The order makes a difference, and globbing Dir produces different results on different machines.
# We can .sort the glob, but still the order would be wrong, and we'd need to have repeated requires in
# Individual files. Michael and I think it's easier to statically call them all in one place in the right order.

require 'dirge' # TODO inclide into gem dependencies

require ~'lib/s_data'
require ~'lib/s_data/exceptions'
require ~'lib/s_data/formatting.rb'
require ~'lib/s_data/collection.rb'
require ~'lib/s_data/atom_extensions.rb'
require ~'lib/s_data/namespace_definitions.rb'
require ~'lib/s_data/predicate.rb'
require ~'lib/s_data/trait.rb'
require ~'lib/s_data/payload.rb'
require ~'lib/s_data/sync/resource_mixin.rb'
require ~'lib/s_data/virtual_base'
require ~'lib/s_data/resource.rb'
require ~'lib/s_data/sync/actions.rb'
require ~'lib/s_data/diagnosis.rb'
require ~'lib/s_data/conditions_builder.rb'
require ~'lib/s_data/application.rb'
