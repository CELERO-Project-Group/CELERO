<?php
namespace App\Models;

use CodeIgniter\Model;

class Cpscoping_model extends Model
{

    public function __construct()
    {
        $this->load->database();
    }

    public function set_cp_allocation($data)
    {
        $this->db->insert('t_cp_allocation', $data);
    }

    public function update_cp_allocation($data, $id)
    {
        $this->db->where('t_cp_allocation.id', $id);
        $this->db->update('t_cp_allocation', $data);
    }

    public function set_cp_allocation_main($data)
    {
        $this->db->insert('t_cp_company_project', $data);
    }

    public function get_allocation_from_allocation_id($allocation_id)
    {
        $this->db->select('t_cp_allocation.id as allocation_id, t_cp_allocation.prcss_id as prcss_id,t_prcss.name as prcss_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name,amount,unit_amount,allocation_amount,error_amount,cost,unit_cost,allocation_cost,error_cost,env_impact,unit_env_impact,allocation_env_impact,error_ep,t_cp_allocation.flow_id as flow_id,t_prcss.id as prcss_id2,t_cp_allocation.flow_type_id as flow_type_id, kpi, unit_kpi, kpi_error, benchmark_kpi,nameofref,kpidef, best_practice, reference, unit_reference, t_cmpny_prcss.cmpny_id, t_cp_allocation.option, t_cp_allocation.description');
        $this->db->from('t_cp_allocation');
        $this->db->join('t_flow', 't_flow.id = t_cp_allocation.flow_id');
        $this->db->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
        $this->db->join('t_cmpny_prcss', 't_cmpny_prcss.id = t_cp_allocation.prcss_id');
        $this->db->join('t_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
        $this->db->where('t_cp_allocation.id', $allocation_id);
        $data = $this->db->get()->row_array();
        //print_r($this->db->last_query());
        return $data;
    }

    public function get_allocation_from_allocation_id_output($allocation_id)
    {
        $this->db->select('t_cp_allocation.id as allocation_id, t_cp_allocation.prcss_id as prcss_id,t_prcss.name as prcss_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name,amount,unit_amount,allocation_amount,error_amount,cost,unit_cost,allocation_cost,error_cost,env_impact,unit_env_impact,allocation_env_impact,error_ep,t_cp_allocation.flow_id,t_cp_allocation.prcss_id');
        $this->db->from('t_cp_allocation');
        $this->db->join('t_flow', 't_flow.id = t_cp_allocation.flow_id');
        $this->db->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
        $this->db->join('t_cmpny_prcss', 't_cmpny_prcss.id = t_cp_allocation.prcss_id');
        $this->db->join('t_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
        $this->db->where('t_cp_allocation.id', $allocation_id);
        $this->db->where('t_cp_allocation.flow_type_id', '2');
        $query = $this->db->get()->row_array();
        if (!empty($query)) {
            return $query;
        }
    }

    //get all process info form flow name and flow type
    public function get_process_id_from_flow_and_type($flow_id, $flow_type_id, $prjct_id)
    {
        $this->db->select('t_cp_allocation.prcss_id,t_cp_allocation.id');
        $this->db->from('t_cp_allocation');
        $this->db->join('t_cp_company_project', 't_cp_allocation.id = t_cp_company_project.allocation_id');
        $this->db->where('t_cp_company_project.prjct_id', $prjct_id);
        $this->db->where('t_cp_allocation.flow_id', $flow_id);
        $this->db->where('t_cp_allocation.flow_type_id', $flow_type_id);
        $query = $this->db->get()->result_array();
        if (!empty($query)) {
            return $query;
        }
    }

    //getting all process of an allocated flow
    public function get_process_from_allocatedpid_and_cmpny_id($prcss_id, $cmpny_id)
    {
        $this->db->select('t_prcss.id as id,t_prcss.name as name');
        $this->db->from('t_prcss');
        $this->db->join('t_cmpny_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
        $this->db->where('t_cmpny_prcss.id', $prcss_id);
        $this->db->where('t_cmpny_prcss.cmpny_id', $cmpny_id);
        $query = $this->db->get()->row_array();
        if (!empty($query)) {
            return $query;
        }
    }

    public function get_allocation_id_from_ids($company_id, $project_id)
    {
        $this->db->select('allocation_id');
        $this->db->from('t_cp_company_project');
        $this->db->where('cmpny_id', $company_id);
        $this->db->where('prjct_id', $project_id);
        $data = $this->db->get()->result_array();
        //print_r($this->db->last_query());
        return $data;
    }

    public function get_allocation_id_from_ids2($company_id, $project_id)
    {
        $this->db->select('*');
        $this->db->from('t_cp_company_project');
        $this->db->where('cmpny_id', $company_id);
        $this->db->where('prjct_id', $project_id);
        return $this->db->get()->result_array();
    }

    /*public function get_allocation_from_fname_pname($flow_id,$process_id,$input_output){
    $this->db->select('t_prcss.name as prcss_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name,amount,unit_amount,allocation_amount,importance_amount,cost,unit_cost,allocation_cost,importance_cost,env_impact,unit_env_impact,allocation_env_impact,importance_env_impact');
    $this->db->from('t_cp_allocation');
    $this->db->join('t_flow','t_flow.id = t_cp_allocation.flow_id');
    $this->db->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
    $this->db->join('t_cmpny_prcss','t_cmpny_prcss.id = t_cp_allocation.prcss_id');
    $this->db->join('t_prcss','t_prcss.id = t_cmpny_prcss.prcss_id');
    $this->db->where('t_cp_allocation.flow_id',$flow_id);
    $this->db->where('t_cp_allocation.prcss_id',$process_id);
    $this->db->where('t_cp_allocation.flow_type_id',$input_output);
    return $this->db->get()->row_array();
    }*/

    public function get_cost_benefit_info($cmpny_id, $prjct_id)
    {
        $this->db->select('*,
        t_cp_allocation.id as cp_id,
        t_cmpny_flow.qntty as qntty,
        t_unit.name as qntty_unit,
        t_cmpny_flow.cost as cost,
        t_cmpny_flow.ep as ep,
        t_cp_allocation.id as allocation_id,
        t_prcss.name as prcss_name,
        t_cp_allocation.reference as reference,
        t_cp_allocation.unit_reference as unit_reference,
        t_flow.name as flow_name,
        t_flow_type.name as flow_type_name,
        t_cp_allocation.best_practice as best,
        t_cp_allocation.marcos as marcos
        ');
        $this->db->from('t_cp_company_project');
        $this->db->join('t_cp_allocation', 't_cp_allocation.id = t_cp_company_project.allocation_id', 'left');
        $this->db->join('t_flow', 't_flow.id = t_cp_allocation.flow_id');
        $this->db->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
        $this->db->join('t_cmpny_prcss', 't_cmpny_prcss.id = t_cp_allocation.prcss_id');
        $this->db->join('t_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
        $this->db->join('t_cmpny_flow', 't_cmpny_flow.flow_id = t_cp_allocation.flow_id and t_cmpny_flow.cmpny_id = t_cp_company_project.cmpny_id and t_cmpny_flow.flow_type_id = t_cp_allocation.flow_type_id', 'left');
        $this->db->join('t_unit', 't_unit.id = t_cmpny_flow.qntty_unit_id');
        $this->db->join('t_costbenefit_temp', 't_costbenefit_temp.cp_id = t_cp_allocation.id', 'left');
        $this->db->where_not_in('t_cp_allocation.best_practice', "");
        $this->db->where('t_cp_company_project.prjct_id', $prjct_id);
        $this->db->where('t_cp_company_project.cmpny_id', $cmpny_id);
        $this->db->where('t_cp_allocation.option', '1');
        $this->db->order_by("t_cp_allocation.marcos", "asc");

        $data = $this->db->get()->result_array();
        //print_r($this->db->last_query());
        //print_r($data);
        return $data;
    }

    public function get_cost_benefit_info_is($cmpny_id, $prjct_id)
    {
        $this->db->select('DISTINCT on ("t_is_prj_details"."id") *,
        t_is_prj_details.id as is_id,
        t_cmpny_flow.qntty as qntty,
        t_unit.name as qntty_unit,
        t_cmpny_flow.cost as cost,
        t_cmpny_flow.ep as ep,
        t_flow.name as flow_name,
        t_cmpny.name as cmpny_from_name,
        ');
        $this->db->from('t_is_prj_details');
        $this->db->join('t_flow', 't_flow.id = t_is_prj_details.flow_id');
        $this->db->join('t_cmpny', 't_cmpny.id = t_is_prj_details.cmpny_from_id');
        $this->db->join('t_cmpny_flow', 't_cmpny_flow.flow_id = t_is_prj_details.flow_id and t_cmpny_flow.cmpny_id = t_is_prj_details.cmpny_to_id');
        $this->db->join('t_unit', 't_unit.id = t_cmpny_flow.qntty_unit_id');
        $this->db->join('t_costbenefit_temp', 't_costbenefit_temp.is_id = t_is_prj_details.id', 'left');
        $this->db->where('t_is_prj_details.cmpny_to_id', $cmpny_id);
        $data = $this->db->get()->result_array();
        //print_r($this->db->last_query());
        //print_r($data);
        return $data;
    }

    public function get_allocation_values($cmpny_id, $prjct_id)
    {
        $this->db->select('t_prcss.name as prcss_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name, t_cp_company_project.allocation_id as allocation_id, t_cp_company_project.prjct_id as project_id, t_cp_company_project.cmpny_id as company_id');
        $this->db->from('t_cp_company_project');
        $this->db->join('t_cp_allocation', 't_cp_allocation.id = t_cp_company_project.allocation_id');
        $this->db->join('t_flow', 't_flow.id = t_cp_allocation.flow_id');
        $this->db->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
        $this->db->join('t_cmpny_prcss', 't_cmpny_prcss.id = t_cp_allocation.prcss_id');
        $this->db->join('t_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
        $this->db->where('t_cp_company_project.prjct_id', $prjct_id);
        $this->db->where('t_cp_company_project.cmpny_id', $cmpny_id);
        $this->db->order_by("t_prcss.name", "asc");
        $this->db->order_by("t_flow.name", "asc");
        $this->db->order_by("t_flow_type.name", "asc");
        return $this->db->get()->result_array();
    }

    public function get_allocation_from_fname_pname_copy($flow_id, $allocation_id, $input_output)
    {
        $this->db->select('t_prcss.name as prcss_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name,amount,unit_amount,allocation_amount,error_amount,cost,unit_cost,allocation_cost,error_cost,env_impact,unit_env_impact,allocation_env_impact,error_ep');
        $this->db->from('t_cp_allocation');
        $this->db->join('t_flow', 't_flow.id = t_cp_allocation.flow_id');
        $this->db->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
        $this->db->join('t_cmpny_prcss', 't_cmpny_prcss.id = t_cp_allocation.prcss_id');
        $this->db->join('t_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
        $this->db->where('t_cp_allocation.id', $allocation_id);
        $this->db->where('t_cp_allocation.flow_id', $flow_id);
        $this->db->where('t_cp_allocation.flow_type_id', $input_output);
        return $this->db->get()->row_array();
    }

    public function get_allocation_prcss_flow_id($allocation_id, $input_output)
    {
        $this->db->select('*');
        $this->db->from('t_cp_allocation');
        $this->db->where('id', $allocation_id);
        $this->db->where('flow_type_id', $input_output);
        return $this->db->get()->row_array();
    }

    public function cp_is_candidate_control($allocation_id)
    {
        $this->db->select('*');
        $this->db->from('t_cp_is_candidate');
        $this->db->where('allocation_id', $allocation_id);
        $query = $this->db->get()->row_array();

        if (!empty($query)) {
            if ($query['active'] == 1) {
                return 1;
            } else {
                return 2;
            }
        } else {
            return 0;
        }
    }

    public function cp_is_candidate_insert($is_candidate_array)
    {
        $this->db->insert('t_cp_is_candidate', $is_candidate_array);
    }

    public function cp_is_candidate_update($is_candidate_array, $allocation_id)
    {
        $this->db->where('allocation_id', $allocation_id);
        $this->db->update('t_cp_is_candidate', $is_candidate_array);
    }

    public function get_is_candidate_active_position($allocation_id)
    {
        $this->db->select('active');
        $this->db->from('t_cp_is_candidate');
        $this->db->where('allocation_id', $allocation_id);
        $query = $this->db->get()->row_array();
        if (empty($query)) {
            return 0;
        } else {
            return $query['active'];
        }
    }

    public function insert_cp_scoping_file($cp_scoping_files)
    {
        $this->db->insert('t_cp_scoping_files', $cp_scoping_files);
    }

    public function delete_cp_scoping_file($cp_scoping_files)
    {
        $this->db->delete('t_cp_scoping_files', $cp_scoping_files);
    }

    public function get_cp_scoping_files($project_id, $cmpny_id)
    {
        $this->db->select('*');
        $this->db->from('t_cp_scoping_files');
        $this->db->where('prjct_id', $project_id);
        $this->db->where('cmpny_id', $cmpny_id);
        return $this->db->get()->result_array();
    }

    public function search_result($search)
    {
        $this->db->from('t_cp_scoping_files');
        $this->db->like('file_name', $search, 'both');
        return $this->db->get()->result_array();
    }

    public function kpi_insert($kpi, $allocation_id)
    {
        $this->db->where('id', $allocation_id);
        $this->db->update('t_cp_allocation', $kpi);
        //print_r($this->db->last_query());
    }

    public function can_consultant_prjct($user_id)
    {
        $this->db->select('prj_id');
        $this->db->from('t_prj_cnsltnt');
        $this->db->where('cnsltnt_id', $user_id);
        $this->db->where('active', '1');
        $query = $this->db->get()->result_array();
        if (!empty($query)) {
            return true;
        } else {
            return false;
        }
    }

    //allocation delete model
    public function delete_allocation($allocation_id, $project_id, $company_id)
    {
        $this->db->where('id', $allocation_id);
        $this->db->delete('t_cp_allocation');
        $this->db->where('allocation_id', $allocation_id);
        $this->db->where('prjct_id', $project_id);
        $this->db->where('cmpny_id', $company_id);
        $this->db->delete('t_cp_company_project');
    }

    //delete allocation by process id
    public function delete_allocation_prcssid($process_id)
    {
        $this->db->where('prcss_id', $process_id);
        $this->db->delete('t_cp_allocation');
    }

}
