module OpenstackHandle
  class PlanningDelegate < DelegateClass(Fog::Openstack::Planning)
    SERVICE_NAME = "Planning"

    def initialize(dobj, os_handle)
      super(dobj)
      @os_handle = os_handle
    end
  end
end
