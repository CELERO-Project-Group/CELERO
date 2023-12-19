<?php

namespace App\Controllers;

use App\Models\Company_model;
use App\Models\Cpscoping_model;
use App\Models\Project_model;
use App\Models\Cost_benefit_model;

class Cost_benefit extends BaseController
{

    public function new_cost_benefit($prjct_id, $cmpny_id)
    {
        $cpscoping_model = model(Cpscoping_model::class);
        $company_model = model(Company_model::class);

        if ($cpscoping_model->can_consultant_prjct($this->session->id) == false) {
            return redirect()->to(site_url(''));
        }
        $allocation_id_array = $cpscoping_model->get_allocation_id_from_ids($cmpny_id, $prjct_id);
        $data['allocation'] = array();
        foreach ($allocation_id_array as $ids) {
            $data['allocated_flows'][] = $cpscoping_model->get_allocation_from_allocation_id($ids['allocation_id']);
        }
        $data['company'] = $company_model->get_company($cmpny_id);
        $data['allocation'] = $cpscoping_model->get_cost_benefit_info($cmpny_id, $prjct_id);
        $data['is'] = $cpscoping_model->get_cost_benefit_info_is($cmpny_id, $prjct_id);

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

    public function saveNewISScopingPotential()
    {

        $Cpscoping_model = model(Cpscoping_model::class);

        $data = $this->request->getPost('companies');

        // Debugging
        echo "<pre>";
        print_r($data);
        echo "</pre>";

        if (is_array($data)) {
            foreach ($data as $entry) {
                if (isset($entry['from_id'], $entry['to_id'], $entry['flow_id'])) {
                    $formattedEntry = [
                        'cmpny_from_id' => $entry['from_id'],
                        'cmpny_to_id' => $entry['to_id'],
                        'flow_id' => $entry['flow_id'],
                        'is_prj_id' => 130,
                    ];

                    $Cpscoping_model->insertNewIsData($formattedEntry);
                } else {
                    echo "One of the entries did not have the expected keys.";
                }
            }
        } else {
            echo "Received data is not an array.";
        }

        // Redirect or do whatever you want after saving
        return redirect()->to(site_url('cost_benefit'));
    }


    //cost-benefit analysis form saving
    public function save($prjct_id, $cmpny_id, $id, $cp_or_is)
    {
        $cpscoping_model = model(Cpscoping_model::class);

        if ($cpscoping_model->can_consultant_prjct($this->session->id) == false) {
            return redirect()->to(site_url(''));
        }

        $fields = [
            'capexold'
            , 'flow-name-1'
            , 'flow-value-1'
            , 'flow-unit-1'
            , 'flow-specost-1'
            , 'flow-opex-1'
            , 'flow-eipunit-1'
            , 'flow-eip-1'
            , 'annual-cost-1'
            , 'ltold'
            , 'investment'
            , 'disrate'
            , 'capex-1'
            , 'flow-name-2'
            , 'flow-value-2'
            , 'flow-unit-2'
            , 'flow-specost-2'
            , 'flow-opex-2'
            , 'flow-eipunit-2'
            , 'flow-eip-2'
            , 'annual-cost-2'
            , 'flow-name-3'
            , 'flow-value-3'
            , 'flow-unit-3'
            , 'flow-opex-3'
            , 'ecoben-1'
            , 'ecoben-eip-1'
            , 'marcos-1'
            , 'payback-1'
            , 'flow-name-1-2'
            , 'flow-value-1-2'
            , 'flow-unit-1-2'
            , 'flow-specost-1-2'
            , 'flow-opex-1-2'
            , 'flow-eipunit-1-2'
            , 'flow-eip-1-2'
            , 'flow-name-2-2'
            , 'flow-value-2-2'
            , 'flow-unit-2-2'
            , 'flow-specost-2-2'
            , 'flow-opex-2-2'
            , 'flow-eipunit-2-2'
            , 'flow-eip-2-2'
            , 'flow-name-3-2'
            , 'flow-value-3-2'
            , 'flow-unit-3-2'
            , 'flow-opex-3-2'
            , 'ecoben-eip-1-2'
            , 'flow-name-1-3'
            , 'flow-value-1-3'
            , 'flow-unit-1-3'
            , 'flow-specost-1-3'
            , 'flow-opex-1-3'
            , 'flow-eipunit-1-3'
            , 'flow-eip-1-3'
            , 'flow-name-2-3'
            , 'flow-value-2-3'
            , 'flow-unit-2-3'
            , 'flow-specost-2-3'
            , 'flow-opex-2-3'
            , 'flow-eipunit-2-3'
            , 'flow-eip-2-3'
            , 'flow-name-3-3'
            , 'flow-value-3-3'
            , 'flow-unit-3-3'
            , 'flow-opex-3-3'
            , 'ecoben-eip-1-3'
            , 'flow-name-1-4'
            , 'flow-value-1-4'
            , 'flow-unit-1-4'
            , 'flow-specost-1-4'
            , 'flow-opex-1-4'
            , 'flow-eipunit-1-4'
            , 'flow-eip-1-4'
            , 'flow-name-2-4'
            , 'flow-value-2-4'
            , 'flow-unit-2-4'
            , 'flow-specost-2-4'
            , 'flow-opex-2-4'
            , 'flow-eipunit-2-4'
            , 'flow-eip-2-4'
            , 'flow-name-3-4'
            , 'flow-value-3-4'
            , 'flow-unit-3-4'
            , 'flow-opex-3-4'
            , 'ecoben-eip-1-4'
            , 'flow-name-1-5'
            , 'flow-value-1-5'
            , 'flow-unit-1-5'
            , 'flow-specost-1-5'
            , 'flow-opex-1-5'
            , 'flow-eipunit-1-5'
            , 'flow-eip-1-5'
            , 'flow-name-2-5'
            , 'flow-value-2-5'
            , 'flow-unit-2-5'
            , 'flow-specost-2-5'
            , 'flow-opex-2-5'
            , 'flow-eipunit-2-5'
            , 'flow-eip-2-5'
            , 'flow-name-3-5'
            , 'flow-value-3-5'
            , 'flow-unit-3-5'
            , 'flow-opex-3-5'
            , 'ecoben-eip-1-5'
            , 'flow-name-1-6'
            , 'flow-value-1-6'
            , 'flow-unit-1-6'
            , 'flow-specost-1-6'
            , 'flow-opex-1-6'
            , 'flow-eipunit-1-6'
            , 'flow-eip-1-6'
            , 'flow-name-2-6'
            , 'flow-value-2-6'
            , 'flow-unit-2-6'
            , 'flow-specost-2-6'
            , 'flow-opex-2-6'
            , 'flow-eipunit-2-6'
            , 'flow-eip-2-6'
            , 'flow-name-3-6'
            , 'flow-value-3-6'
            , 'flow-unit-3-6'
            , 'flow-opex-3-6'
            , 'ecoben-eip-1-6'
            , 'maintan-1'
            , 'sum-1'
            , 'sum-2'
            , 'maintan-1-2'
            , 'sum-1-1'
            , 'sum-2-1'
            , 'sum-3-1'
            , 'sum-3-2'
            , 'cp_or_is'];

        // Extract data from POST
        $data = [];
        foreach ($fields as $field) {
            $data[$field] = $this->request->getPost($field);
        }

        // Save data using the cost_benefit_model
        $this->cost_benefit_model->set_cba($id, ...array_values($data));

        redirect('cost_benefit/' . $prjct_id . '/' . $cmpny_id);
    }

}
