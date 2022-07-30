<?php

namespace App\Controllers;

class Cost_benefit extends BaseController
{

    public function new_cost_benefit($prjct_id, $cmpny_id)
    {
        $cpscoping_model = model(Cpscoping_model::class);
        $company_model = model(Company_model::class);

        if ($cpscoping_model->can_consultant_prjct($this->session->id) == false) {
            return redirect()->to(site_url(''));
        }
        $allocation_id_array = $cpscoping_model->get_allocation_id_from_ids($cmpny_id,$prjct_id);
        $data['allocation'] = array();
        foreach ($allocation_id_array as $ids) {
            $data['allocated_flows'][] = $cpscoping_model->get_allocation_from_allocation_id($ids['allocation_id']);
        }
        $data['company']    = $company_model->get_company($cmpny_id);
        $data['allocation'] = $cpscoping_model->get_cost_benefit_info($cmpny_id, $prjct_id);
        $data['is']         = $cpscoping_model->get_cost_benefit_info_is($cmpny_id, $prjct_id);
        
        echo view('template/header');
        echo view('cost_benefit/index', $data);
        echo view('template/footer');
    }

    public function index()
    {
        $cpscoping_model = model(Cpscoping_model::class);
        $project_model = model(Project_model::class);

        if ($cpscoping_model->can_consultant_prjct($this->session->id) == false) {
            return redirect()->to(site_url(''));
        }
        $data['com_pro'] = $project_model->get_prj_companies(session()->project_id);

        echo view('template/header');
        echo view('cost_benefit/list', $data);
        echo view('template/footer');
    }

    //cost-benefit analysis form saving
    public function save($prjct_id, $cmpny_id, $id, $cp_or_is)
    {
        $cpscoping_model = model(Cpscoping_model::class);

        if ($cpscoping_model->can_consultant_prjct($this->session->id) == false) {
            return redirect()->to(site_url(''));
        }
        //TODO: Maybe we can find a better way to do it :)
        $capexold         = $this->request->getPost('capexold');
        $flow_name_1      = $this->request->getPost('flow-name-1');
        $flow_value_1     = $this->request->getPost('flow-value-1');
        $flow_unit_1      = $this->request->getPost('flow-unit-1');
        $flow_specost_1   = $this->request->getPost('flow-specost-1');
        $flow_opex_1      = $this->request->getPost('flow-opex-1');
        $flow_eipunit_1   = $this->request->getPost('flow-eipunit-1');
        $floweip_1        = $this->request->getPost('flow-eip-1');
        $annual_cost_1    = $this->request->getPost('annual-cost-1');
        $ltold            = $this->request->getPost('ltold');
        $investment       = $this->request->getPost('investment');
        $disrate          = $this->request->getPost('disrate');
        $capex_1          = $this->request->getPost('capex-1');
        $flow_name_2      = $this->request->getPost('flow-name-2');
        $flow_value_2     = $this->request->getPost('flow-value-2');
        $flow_unit_2      = $this->request->getPost('flow-unit-2');
        $flow_specost_2   = $this->request->getPost('flow-specost-2');
        $flow_opex_2      = $this->request->getPost('flow-opex-2');
        $flow_eipunit_2   = $this->request->getPost('flow-eipunit-2');
        $flow_eip_2       = $this->request->getPost('flow-eip-2');
        $annual_cost_2    = $this->request->getPost('annual-cost-2');
        $flow_name_3      = $this->request->getPost('flow-name-3');
        $flow_value_3     = $this->request->getPost('flow-value-3');
        $flow_unit_3      = $this->request->getPost('flow-unit-3');
        $flow_opex_3      = $this->request->getPost('flow-opex-3');
        $ecoben_1         = $this->request->getPost('ecoben-1');
        $ecoben_eip_1     = $this->request->getPost('ecoben-eip-1');
        $marcos_1         = $this->request->getPost('marcos-1');
        $payback_1        = $this->request->getPost('payback-1');
        $flow_name_1_2    = $this->request->getPost('flow-name-1-2');
        $flow_value_1_2   = $this->request->getPost('flow-value-1-2');
        $flow_unit_1_2    = $this->request->getPost('flow-unit-1-2');
        $flow_specost_1_2 = $this->request->getPost('flow-specost-1-2');
        $flow_opex_1_2    = $this->request->getPost('flow-opex-1-2');
        $flow_eipunit_1_2 = $this->request->getPost('flow-eipunit-1-2');
        $flow_eip_1_2     = $this->request->getPost('flow-eip-1-2');
        $flow_name_2_2    = $this->request->getPost('flow-name-2-2');
        $flow_value_2_2   = $this->request->getPost('flow-value-2-2');
        $flow_unit_2_2    = $this->request->getPost('flow-unit-2-2');
        $flow_specost_2_2 = $this->request->getPost('flow-specost-2-2');
        $flow_opex_2_2    = $this->request->getPost('flow-opex-2-2');
        $flow_eipunit_2_2 = $this->request->getPost('flow-eipunit-2-2');
        $flow_eip_2_2     = $this->request->getPost('flow-eip-2-2');
        $flow_name_3_2    = $this->request->getPost('flow-name-3-2');
        $flow_value_3_2   = $this->request->getPost('flow-value-3-2');
        $flow_unit_3_2    = $this->request->getPost('flow-unit-3-2');
        $flow_opex_3_2    = $this->request->getPost('flow-opex-3-2');
        $ecoben_eip_1_2   = $this->request->getPost('ecoben-eip-1-2');
        $flow_name_1_3    = $this->request->getPost('flow-name-1-3');
        $flow_value_1_3   = $this->request->getPost('flow-value-1-3');
        $flow_unit_1_3    = $this->request->getPost('flow-unit-1-3');
        $flow_specost_1_3 = $this->request->getPost('flow-specost-1-3');
        $flow_opex_1_3    = $this->request->getPost('flow-opex-1-3');
        $flow_eipunit_1_3 = $this->request->getPost('flow-eipunit-1-3');
        $flow_eip_1_3     = $this->request->getPost('flow-eip-1-3');
        $flow_name_2_3    = $this->request->getPost('flow-name-2-3');
        $flow_value_2_3   = $this->request->getPost('flow-value-2-3');
        $flow_unit_2_3    = $this->request->getPost('flow-unit-2-3');
        $flow_specost_2_3 = $this->request->getPost('flow-specost-2-3');
        $flow_opex_2_3    = $this->request->getPost('flow-opex-2-3');
        $flow_eipunit_2_3 = $this->request->getPost('flow-eipunit-2-3');
        $flow_eip_2_3     = $this->request->getPost('flow-eip-2-3');
        $flow_name_3_3    = $this->request->getPost('flow-name-3-3');
        $flow_value_3_3   = $this->request->getPost('flow-value-3-3');
        $flow_unit_3_3    = $this->request->getPost('flow-unit-3-3');
        $flow_opex_3_3    = $this->request->getPost('flow-opex-3-3');
        $ecoben_eip_1_3   = $this->request->getPost('ecoben-eip-1-3');
        $flow_name_1_4    = $this->request->getPost('flow-name-1-4');
        $flow_value_1_4   = $this->request->getPost('flow-value-1-4');
        $flow_unit_1_4    = $this->request->getPost('flow-unit-1-4');
        $flow_specost_1_4 = $this->request->getPost('flow-specost-1-4');
        $flow_opex_1_4    = $this->request->getPost('flow-opex-1-4');
        $flow_eipunit_1_4 = $this->request->getPost('flow-eipunit-1-4');
        $flow_eip_1_4     = $this->request->getPost('flow-eip-1-4');
        $flow_name_2_4    = $this->request->getPost('flow-name-2-4');
        $flow_value_2_4   = $this->request->getPost('flow-value-2-4');
        $flow_unit_2_4    = $this->request->getPost('flow-unit-2-4');
        $flow_specost_2_4 = $this->request->getPost('flow-specost-2-4');
        $flow_opex_2_4    = $this->request->getPost('flow-opex-2-4');
        $flow_eipunit_2_4 = $this->request->getPost('flow-eipunit-2-4');
        $flow_eip_2_4     = $this->request->getPost('flow-eip-2-4');
        $flow_name_3_4    = $this->request->getPost('flow-name-3-4');
        $flow_value_3_4   = $this->request->getPost('flow-value-3-4');
        $flow_unit_3_4    = $this->request->getPost('flow-unit-3-4');
        $flow_opex_3_4    = $this->request->getPost('flow-opex-3-4');
        $ecoben_eip_1_4   = $this->request->getPost('ecoben-eip-1-4');
        $flow_name_1_5    = $this->request->getPost('flow-name-1-5');
        $flow_value_1_5   = $this->request->getPost('flow-value-1-5');
        $flow_unit_1_5    = $this->request->getPost('flow-unit-1-5');
        $flow_specost_1_5 = $this->request->getPost('flow-specost-1-5');
        $flow_opex_1_5    = $this->request->getPost('flow-opex-1-5');
        $flow_eipunit_1_5 = $this->request->getPost('flow-eipunit-1-5');
        $flow_eip_1_5     = $this->request->getPost('flow-eip-1-5');
        $flow_name_2_5    = $this->request->getPost('flow-name-2-5');
        $flow_value_2_5   = $this->request->getPost('flow-value-2-5');
        $flow_unit_2_5    = $this->request->getPost('flow-unit-2-5');
        $flow_specost_2_5 = $this->request->getPost('flow-specost-2-5');
        $flow_opex_2_5    = $this->request->getPost('flow-opex-2-5');
        $flow_eipunit_2_5 = $this->request->getPost('flow-eipunit-2-5');
        $flow_eip_2_5     = $this->request->getPost('flow-eip-2-5');
        $flow_name_3_5    = $this->request->getPost('flow-name-3-5');
        $flow_value_3_5   = $this->request->getPost('flow-value-3-5');
        $flow_unit_3_5    = $this->request->getPost('flow-unit-3-5');
        $flow_opex_3_5    = $this->request->getPost('flow-opex-3-5');
        $ecoben_eip_1_5   = $this->request->getPost('ecoben-eip-1-5');
        $flow_name_1_6    = $this->request->getPost('flow-name-1-6');
        $flow_value_1_6   = $this->request->getPost('flow-value-1-6');
        $flow_unit_1_6    = $this->request->getPost('flow-unit-1-6');
        $flow_specost_1_6 = $this->request->getPost('flow-specost-1-6');
        $flow_opex_1_6    = $this->request->getPost('flow-opex-1-6');
        $flow_eipunit_1_6 = $this->request->getPost('flow-eipunit-1-6');
        $flow_eip_1_6     = $this->request->getPost('flow-eip-1-6');
        $flow_name_2_6    = $this->request->getPost('flow-name-2-6');
        $flow_value_2_6   = $this->request->getPost('flow-value-2-6');
        $flow_unit_2_6    = $this->request->getPost('flow-unit-2-6');
        $flow_specost_2_6 = $this->request->getPost('flow-specost-2-6');
        $flow_opex_2_6    = $this->request->getPost('flow-opex-2-6');
        $flow_eipunit_2_6 = $this->request->getPost('flow-eipunit-2-6');
        $flow_eip_2_6     = $this->request->getPost('flow-eip-2-6');
        $flow_name_3_6    = $this->request->getPost('flow-name-3-6');
        $flow_value_3_6   = $this->request->getPost('flow-value-3-6');
        $flow_unit_3_6    = $this->request->getPost('flow-unit-3-6');
        $flow_opex_3_6    = $this->request->getPost('flow-opex-3-6');
        $ecoben_eip_1_6   = $this->request->getPost('ecoben-eip-1-6');
        $maintan_1        = $this->request->getPost('maintan-1');
        $sum_1            = $this->request->getPost('sum-1');
        $sum_2            = $this->request->getPost('sum-2');
        $maintan_1_2      = $this->request->getPost('maintan-1-2');
        $sum_1_1          = $this->request->getPost('sum-1-1');
        $sum_2_1          = $this->request->getPost('sum-2-1');
        $sum_3_1          = $this->request->getPost('sum-3-1');
        $sum_3_2          = $this->request->getPost('sum-3-2');
        $cp_or_is         = $this->request->getPost('cp_or_is');

        $this->cost_benefit_model->set_cba($id, $capexold,
            $flow_name_1,
            $flow_value_1,
            $flow_unit_1,
            $flow_specost_1,
            $flow_opex_1,
            $flow_eipunit_1,
            $floweip_1,
            $annual_cost_1,
            $ltold,
            $investment,
            $disrate,
            $capex_1,
            $flow_name_2,
            $flow_value_2,
            $flow_unit_2,
            $flow_specost_2,
            $flow_opex_2,
            $flow_eipunit_2,
            $flow_eip_2,
            $annual_cost_2,
            $flow_name_3,
            $flow_value_3,
            $flow_unit_3,
            $flow_opex_3,
            $ecoben_1,
            $ecoben_eip_1,
            $marcos_1,
            $payback_1,
            $flow_name_1_2,
            $flow_value_1_2,
            $flow_unit_1_2,
            $flow_specost_1_2,
            $flow_opex_1_2,
            $flow_eipunit_1_2,
            $flow_eip_1_2,
            $flow_name_2_2,
            $flow_value_2_2,
            $flow_unit_2_2,
            $flow_specost_2_2,
            $flow_opex_2_2,
            $flow_eipunit_2_2,
            $flow_eip_2_2,
            $flow_name_3_2,
            $flow_value_3_2,
            $flow_unit_3_2,
            $flow_opex_3_2,
            $ecoben_eip_1_2,
            $flow_name_1_3,
            $flow_value_1_3,
            $flow_unit_1_3,
            $flow_specost_1_3,
            $flow_opex_1_3,
            $flow_eipunit_1_3,
            $flow_eip_1_3,
            $flow_name_2_3,
            $flow_value_2_3,
            $flow_unit_2_3,
            $flow_specost_2_3,
            $flow_opex_2_3,
            $flow_eipunit_2_3,
            $flow_eip_2_3,
            $flow_name_3_3,
            $flow_value_3_3,
            $flow_unit_3_3,
            $flow_opex_3_3,
            $ecoben_eip_1_3,
            $flow_name_1_4,
            $flow_value_1_4,
            $flow_unit_1_4,
            $flow_specost_1_4,
            $flow_opex_1_4,
            $flow_eipunit_1_4,
            $flow_eip_1_4,
            $flow_name_2_4,
            $flow_value_2_4,
            $flow_unit_2_4,
            $flow_specost_2_4,
            $flow_opex_2_4,
            $flow_eipunit_2_4,
            $flow_eip_2_4,
            $flow_name_3_4,
            $flow_value_3_4,
            $flow_unit_3_4,
            $flow_opex_3_4,
            $ecoben_eip_1_4,
            $flow_name_1_5,
            $flow_value_1_5,
            $flow_unit_1_5,
            $flow_specost_1_5,
            $flow_opex_1_5,
            $flow_eipunit_1_5,
            $flow_eip_1_5,
            $flow_name_2_5,
            $flow_value_2_5,
            $flow_unit_2_5,
            $flow_specost_2_5,
            $flow_opex_2_5,
            $flow_eipunit_2_5,
            $flow_eip_2_5,
            $flow_name_3_5,
            $flow_value_3_5,
            $flow_unit_3_5,
            $flow_opex_3_5,
            $ecoben_eip_1_5,
            $flow_name_1_6,
            $flow_value_1_6,
            $flow_unit_1_6,
            $flow_specost_1_6,
            $flow_opex_1_6,
            $flow_eipunit_1_6,
            $flow_eip_1_6,
            $flow_name_2_6,
            $flow_value_2_6,
            $flow_unit_2_6,
            $flow_specost_2_6,
            $flow_opex_2_6,
            $flow_eipunit_2_6,
            $flow_eip_2_6,
            $flow_name_3_6,
            $flow_value_3_6,
            $flow_unit_3_6,
            $flow_opex_3_6,
            $ecoben_eip_1_6,
            $maintan_1,
            $sum_1,
            $sum_2,
            $maintan_1_2,
            $sum_1_1,
            $sum_2_1,
            $sum_3_1,
            $sum_3_2,
        	$cp_or_is);
        redirect('cost_benefit/' . $prjct_id . '/' . $cmpny_id);
    }

}
