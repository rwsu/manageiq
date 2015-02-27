class EmsInfraController < ApplicationController
  include EmsCommon        # common methods for EmsInfra/Cloud controllers

  before_filter :check_privileges
  before_filter :get_session_data
  after_filter :cleanup_action
  after_filter :set_session_data

  def self.model
    @model ||= EmsInfra
  end

  def self.table_name
    @table_name ||= "ems_infra"
  end

  def index
    redirect_to :action => 'show_list'
  end
  
  def scaling
    assert_privileges("ems_infra_scale")
    if params[:cancel]
      redirect_to :action => 'show', :id => params[:id]
    end
    
    drop_breadcrumb(:name => _("Scale Infrastructure Provider"), :url => "/ems_infra/scaling")
    @infra = EmsOpenstackInfra.find(params[:id])
    @stack = @infra.orchestration_stacks.first
    @count_parameters = @stack.parameters.select {|x| x.name.to_s.include?('::count')}
    
    if params[:scale]
      scale_parameters = params.select { |k,v| k.include?('::count')}
    
      # Validate number of selected hosts is not more than available
      assigned_hosts = 0
      scale_parameters.each_value { |value| assigned_hosts += Integer(value) }
      infra = EmsOpenstackInfra.find(params[:id])
      if assigned_hosts > infra.hosts.count
        add_flash(_("Assigning #{assigned_hosts} but only have #{infra.hosts.count} hosts available"), :error)
        $log.error(_("Assigning #{assigned_hosts} but only have #{infra.hosts.count} hosts available."))
      else
        scale_parameters_formatted = []
        for k, v in scale_parameters
          scale_parameters_formatted << {"name" => k, "value" => v}
        end
        stack = OrchestrationStackOpenstackInfra.find(params[:orchestration_stack_id])
        stack.raw_update_stack(:parameters => scale_parameters_formatted)
      end
    end
  end

  private ############################

  def get_session_data
    @title      = ui_lookup(:tables => "ems_infra")
    @layout     = "ems_infra"
    @table_name = request.parameters[:controller]
    @model      = EmsInfra
    @lastaction = session[:ems_infra_lastaction]
    @display    = session[:ems_infra_display]
    @filters    = session[:ems_infra_filters]
    @catinfo    = session[:ems_infra_catinfo]
  end

  def set_session_data
    session[:ems_infra_lastaction] = @lastaction
    session[:ems_infra_display]    = @display unless @display.nil?
    session[:ems_infra_filters]    = @filters
    session[:ems_infra_catinfo]    = @catinfo
  end

end
