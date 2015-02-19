class OrchestrationStackOpenstackInfra < OrchestrationStack
  def raw_update_stack(options)
    ext_management_system.with_provider_connection(:service => "Planning") do |connection|
      # Send new parameters to Tuskar and get updated plan
      plan = connection.plans.get_by_name(name).patch(options)

      # Get all parameters needed for heat stack-update from Tuskar
      planning_data = {
        :stack_name       => name,
        :template         => plan.master_template,
        :environment      => plan.environment,
        :files            => plan.provider_resource_templates
      }
    end

    ext_management_system.with_provider_connection(:service => "Orchestration") do |connection|
      # Update stack with updated planning data
      connection.update_stack(name, ems_ref, planning_data)
    end
  end
end
