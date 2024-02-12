<?php
namespace App\Models;

use CodeIgniter\Model;

class Cost_benefit_model extends Model
{

    public function get_is_candidates()
    {
        $db = db_connect();
        $builder = $db->table('t_cp_is_candidate');
        $builder->select('allocation_id');
        $builder->where('active', '1');
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function get_allocation_ids($allocation_id, $prjct_id, $cmpny_id)
    {
        $db = db_connect();
        $builder = $db->table('t_cp_company_project');
        $builder->select('id');
        $builder->where('allocation_id', $allocation_id);
        $builder->where('prjct_id', $prjct_id);
        $builder->where('cmpny_id', $cmpny_id);
        $query = $builder->get()->getRowArray();
        if (!empty($query)) {
            return true;
        } else {
            return false;
        }
    }

    public function set_cba($id, $capexold,
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
        $cp_or_is) {
        $flag = $this->is_cb_exist($id);

        $data = array(
            'capexold'         => $capexold,
            'flow-name-1'      => $flow_name_1,
            'flow-value-1'     => $flow_value_1,
            'flow-unit-1'      => $flow_unit_1,
            'flow-specost-1'   => $flow_specost_1,
            'flow-opex-1'      => $flow_opex_1,
            'flow-eipunit-1'   => $flow_eipunit_1,
            'floweip-1'        => $floweip_1,
            'annual-cost-1'    => $annual_cost_1,
            'ltold'            => $ltold,
            'investment'       => $investment,
            'disrate'          => $disrate,
            'capex-1'          => $capex_1,
            'flow-name-2'      => $flow_name_2,
            'flow-value-2'     => $flow_value_2,
            'flow-unit-2'      => $flow_unit_2,
            'flow-specost-2'   => $flow_specost_2,
            'flow-opex-2'      => $flow_opex_2,
            'flow-eipunit-2'   => $flow_eipunit_2,
            'flow-eip-2'       => $flow_eip_2,
            'annual-cost-2'    => $annual_cost_2,
            'flow-name-3'      => $flow_name_3,
            'flow-value-3'     => $flow_value_3,
            'flow-unit-3'      => $flow_unit_3,
            'flow-opex-3'      => $flow_opex_3,
            'ecoben-1'         => $ecoben_1,
            'ecoben-eip-1'     => $ecoben_eip_1,
            'marcos-1'         => $marcos_1,
            'payback-1'        => $payback_1,
            'flow-name-1-2'    => $flow_name_1_2,
            'flow-value-1-2'   => $flow_value_1_2,
            'flow-unit-1-2'    => $flow_unit_1_2,
            'flow-specost-1-2' => $flow_specost_1_2,
            'flow-opex-1-2'    => $flow_opex_1_2,
            'flow-eipunit-1-2' => $flow_eipunit_1_2,
            'flow-eip-1-2'     => $flow_eip_1_2,
            'flow-name-2-2'    => $flow_name_2_2,
            'flow-value-2-2'   => $flow_value_2_2,
            'flow-unit-2-2'    => $flow_unit_2_2,
            'flow-specost-2-2' => $flow_specost_2_2,
            'flow-opex-2-2'    => $flow_opex_2_2,
            'flow-eipunit-2-2' => $flow_eipunit_2_2,
            'flow-eip-2-2'     => $flow_eip_2_2,
            'flow-name-3-2'    => $flow_name_3_2,
            'flow-value-3-2'   => $flow_value_3_2,
            'flow-unit-3-2'    => $flow_unit_3_2,
            'flow-opex-3-2'    => $flow_opex_3_2,
            'ecoben-eip-1-2'   => $ecoben_eip_1_2,
            'flow-name-1-3'    => $flow_name_1_3,
            'flow-value-1-3'   => $flow_value_1_3,
            'flow-unit-1-3'    => $flow_unit_1_3,
            'flow-specost-1-3' => $flow_specost_1_3,
            'flow-opex-1-3'    => $flow_opex_1_3,
            'flow-eipunit-1-3' => $flow_eipunit_1_3,
            'flow-eip-1-3'     => $flow_eip_1_3,
            'flow-name-2-3'    => $flow_name_2_3,
            'flow-value-2-3'   => $flow_value_2_3,
            'flow-unit-2-3'    => $flow_unit_2_3,
            'flow-specost-2-3' => $flow_specost_2_3,
            'flow-opex-2-3'    => $flow_opex_2_3,
            'flow-eipunit-2-3' => $flow_eipunit_2_3,
            'flow-eip-2-3'     => $flow_eip_2_3,
            'flow-name-3-3'    => $flow_name_3_3,
            'flow-value-3-3'   => $flow_value_3_3,
            'flow-unit-3-3'    => $flow_unit_3_3,
            'flow-opex-3-3'    => $flow_opex_3_3,
            'ecoben-eip-1-3'   => $ecoben_eip_1_3,
            'flow-name-1-4'    => $flow_name_1_4,
            'flow-value-1-4'   => $flow_value_1_4,
            'flow-unit-1-4'    => $flow_unit_1_4,
            'flow-specost-1-4' => $flow_specost_1_4,
            'flow-opex-1-4'    => $flow_opex_1_4,
            'flow-eipunit-1-4' => $flow_eipunit_1_4,
            'flow-eip-1-4'     => $flow_eip_1_4,
            'flow-name-2-4'    => $flow_name_2_4,
            'flow-value-2-4'   => $flow_value_2_4,
            'flow-unit-2-4'    => $flow_unit_2_4,
            'flow-specost-2-4' => $flow_specost_2_4,
            'flow-opex-2-4'    => $flow_opex_2_4,
            'flow-eipunit-2-4' => $flow_eipunit_2_4,
            'flow-eip-2-4'     => $flow_eip_2_4,
            'flow-name-3-4'    => $flow_name_3_4,
            'flow-value-3-4'   => $flow_value_3_4,
            'flow-unit-3-4'    => $flow_unit_3_4,
            'flow-opex-3-4'    => $flow_opex_3_4,
            'ecoben-eip-1-4'   => $ecoben_eip_1_4,
            'flow-name-1-5'    => $flow_name_1_5,
            'flow-value-1-5'   => $flow_value_1_5,
            'flow-unit-1-5'    => $flow_unit_1_5,
            'flow-specost-1-5' => $flow_specost_1_5,
            'flow-opex-1-5'    => $flow_opex_1_5,
            'flow-eipunit-1-5' => $flow_eipunit_1_5,
            'flow-eip-1-5'     => $flow_eip_1_5,
            'flow-name-2-5'    => $flow_name_2_5,
            'flow-value-2-5'   => $flow_value_2_5,
            'flow-unit-2-5'    => $flow_unit_2_5,
            'flow-specost-2-5' => $flow_specost_2_5,
            'flow-opex-2-5'    => $flow_opex_2_5,
            'flow-eipunit-2-5' => $flow_eipunit_2_5,
            'flow-eip-2-5'     => $flow_eip_2_5,
            'flow-name-3-5'    => $flow_name_3_5,
            'flow-value-3-5'   => $flow_value_3_5,
            'flow-unit-3-5'    => $flow_unit_3_5,
            'flow-opex-3-5'    => $flow_opex_3_5,
            'ecoben-eip-1-5'   => $ecoben_eip_1_5,
            'flow-name-1-6'    => $flow_name_1_6,
            'flow-value-1-6'   => $flow_value_1_6,
            'flow-unit-1-6'    => $flow_unit_1_6,
            'flow-specost-1-6' => $flow_specost_1_6,
            'flow-opex-1-6'    => $flow_opex_1_6,
            'flow-eipunit-1-6' => $flow_eipunit_1_6,
            'flow-eip-1-6'     => $flow_eip_1_6,
            'flow-name-2-6'    => $flow_name_2_6,
            'flow-value-2-6'   => $flow_value_2_6,
            'flow-unit-2-6'    => $flow_unit_2_6,
            'flow-specost-2-6' => $flow_specost_2_6,
            'flow-opex-2-6'    => $flow_opex_2_6,
            'flow-eipunit-2-6' => $flow_eipunit_2_6,
            'flow-eip-2-6'     => $flow_eip_2_6,
            'flow-name-3-6'    => $flow_name_3_6,
            'flow-value-3-6'   => $flow_value_3_6,
            'flow-unit-3-6'    => $flow_unit_3_6,
            'flow-opex-3-6'    => $flow_opex_3_6,
            'ecoben-eip-1-6'   => $ecoben_eip_1_6,
            'maintan-1'        => $maintan_1,
            'sum-1'            => $sum_1,
            'sum-2'            => $sum_2,
            'maintan-1-2'      => $maintan_1_2,
            'sum-1-1'          => $sum_1_1,
            'sum-2-1'          => $sum_2_1,
            'sum-3-1'          => $sum_3_1,
            'sum-3-2'          => $sum_3_2,
        );
        
        if ($cp_or_is == "is") {
           
            $data['is_id'] = $id;

            if ($flag) {
                $db = db_connect();
                $builder = $db->table('t_costbenefit_temp');
                $builder->where('is_id', $id);
                $builder->update($data);

            } else {
                $db = db_connect();
                $builder = $db->table('t_costbenefit_temp');
                $builder->insert($data);
            }
        } else {
          
            $data['cp_id'] = $id;

            if ($flag) {
                $db = db_connect();
                $builder = $db->table('t_costbenefit_temp');
                $builder->where('cp_id', $id);
                $builder->update($data);

            } else {
                $db = db_connect();
                $builder = $db->table('t_costbenefit_temp');
                $builder->insert($data);
            }
        }
    }

    public function is_cb_exist($id)
    {
        $db = db_connect();
        $builder = $db->table('t_costbenefit_temp');
        $builder->select('1');
        $builder->where('is_id', $id);
        $builder->orWhere('cp_id', $id);
        $count = $builder->countAllResults();
    
        return $count > 0;

    }

}
