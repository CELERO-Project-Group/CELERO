<?php
namespace App\Models;

use CodeIgniter\Model;

class Cpscoping_model extends Model
{

	public function set_cp_allocation($data)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_allocation');
		$builder->insert($data);
		return $db->insertID();
	}

	public function update_cp_allocation($data, $id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_allocation');
		$builder->where('t_cp_allocation.id', $id);
		$builder->update($data);
	}

	public function set_cp_allocation_main($data)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_company_project');
		$builder->insert($data);
	}

	public function get_allocation_from_allocation_id($allocation_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_allocation');
		$builder->select('t_cp_allocation.id as allocation_id, t_cp_allocation.prcss_id as prcss_id,t_prcss.name as prcss_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name,amount,unit_amount,allocation_amount,error_amount,cost,unit_cost,allocation_cost,error_cost,env_impact,unit_env_impact,allocation_env_impact,error_ep,t_cp_allocation.flow_id as flow_id,t_prcss.id as prcss_id2,t_cp_allocation.flow_type_id as flow_type_id, kpi, unit_kpi, kpi_error, benchmark_kpi,nameofref,kpidef, best_practice, reference, unit_reference, t_cmpny_prcss.cmpny_id, t_cp_allocation.option, t_cp_allocation.description');
		$builder->join('t_flow', 't_flow.id = t_cp_allocation.flow_id');
		$builder->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
		$builder->join('t_cmpny_prcss', 't_cmpny_prcss.id = t_cp_allocation.prcss_id');
		$builder->join('t_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
		$builder->where('t_cp_allocation.id', $allocation_id);
		$query = $builder->get()->getRowArray();
		return $query;
	}

	public function get_allocation_from_allocation_id_output($allocation_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_allocation');
		$builder->select('t_cp_allocation.id as allocation_id, t_cp_allocation.prcss_id as prcss_id,t_prcss.name as prcss_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name,amount,unit_amount,allocation_amount,error_amount,cost,unit_cost,allocation_cost,error_cost,env_impact,unit_env_impact,allocation_env_impact,error_ep,t_cp_allocation.flow_id,t_cp_allocation.prcss_id');
		$builder->join('t_flow', 't_flow.id = t_cp_allocation.flow_id');
		$builder->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
		$builder->join('t_cmpny_prcss', 't_cmpny_prcss.id = t_cp_allocation.prcss_id');
		$builder->join('t_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
		$builder->where('t_cp_allocation.id', $allocation_id);
		$builder->where('t_cp_allocation.flow_type_id', '2');
		$query = $builder->get()->getRowArray();
		if (!empty($query)) {
			return $query;
		}
	}

	//get all process info form flow name and flow type
	public function get_process_id_from_flow_and_type($flow_id, $flow_type_id, $prjct_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_allocation');
		$builder->select('t_cp_allocation.prcss_id,t_cp_allocation.id');
		$builder->join('t_cp_company_project', 't_cp_allocation.id = t_cp_company_project.allocation_id');
		$builder->where('t_cp_company_project.prjct_id', $prjct_id);
		$builder->where('t_cp_allocation.flow_id', $flow_id);
		$builder->where('t_cp_allocation.flow_type_id', $flow_type_id);
		$query = $builder->get()->getResultArray();
		if (!empty($query)) {
			return $query;
		}
	}

	//getting all process of an allocated flow
	public function get_process_from_allocatedpid_and_cmpny_id($prcss_id, $cmpny_id)
	{
		$db = db_connect();
		$builder = $db->table('t_prcss');
		$builder->select('t_prcss.id as id,t_prcss.name as name');
		$builder->join('t_cmpny_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
		$builder->where('t_cmpny_prcss.id', $prcss_id);
		$builder->where('t_cmpny_prcss.cmpny_id', $cmpny_id);
		$query = $builder->get()->getRowArray();
		if (!empty($query)) {
			return $query;
		}
	}

	public function get_allocation_id_from_ids($company_id, $project_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_company_project');
		$builder->select('allocation_id');
		$builder->where('cmpny_id', $company_id);
		$builder->where('prjct_id', $project_id);
		$data = $builder->get()->getResultArray();
		return $data;
	}

	public function get_allocation_id_from_ids2($company_id, $project_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_company_project');
		$builder->select('*');
		$builder->where('cmpny_id', $company_id);
		$builder->where('prjct_id', $project_id);
		return $builder->get()->getResultArray();
	}

	public function get_cost_benefit_info($cmpny_id, $prjct_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_company_project');
		$builder->select('*,
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
		$builder->join('t_cp_allocation', 't_cp_allocation.id = t_cp_company_project.allocation_id', 'left');
		$builder->join('t_flow', 't_flow.id = t_cp_allocation.flow_id');
		$builder->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
		$builder->join('t_cmpny_prcss', 't_cmpny_prcss.id = t_cp_allocation.prcss_id');
		$builder->join('t_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
		$builder->join('t_cmpny_flow', 't_cmpny_flow.flow_id = t_cp_allocation.flow_id and t_cmpny_flow.cmpny_id = t_cp_company_project.cmpny_id and t_cmpny_flow.flow_type_id = t_cp_allocation.flow_type_id', 'left');
		$builder->join('t_unit', 't_unit.id = t_cmpny_flow.qntty_unit_id');
		$builder->join('t_costbenefit_temp', 't_costbenefit_temp.cp_id = t_cp_allocation.id', 'left');
		$builder->where('t_cp_company_project.prjct_id', $prjct_id);
		$builder->where('t_cp_company_project.cmpny_id', $cmpny_id);
		$builder->where('t_cp_allocation.option', '1');
		$builder->orderBy("t_cp_allocation.marcos", "asc");
		$data = $builder->get()->getResultArray();
		return $data;
	}

	public function get_cost_benefit_info_is($cmpny_id, $prjct_id)
	{
		$db = db_connect();
		$builder = $db->table('t_is_prj_details');
		$builder->select('DISTINCT on ("t_is_prj_details"."id") *,
		t_is_prj_details.id as is_id,
		t_cmpny_flow.qntty as qntty,
		t_unit.name as qntty_unit,
		t_cmpny_flow.cost as cost,
		t_cmpny_flow.ep as ep,
		t_flow.name as flow_name,
		t_cmpny.name as cmpny_from_name,
		');
		$builder->join('t_flow', 't_flow.id = t_is_prj_details.flow_id');
		$builder->join('t_cmpny', 't_cmpny.id = t_is_prj_details.cmpny_from_id');
		$builder->join('t_cmpny_flow', 't_cmpny_flow.flow_id = t_is_prj_details.flow_id and t_cmpny_flow.cmpny_id = t_is_prj_details.cmpny_to_id');
		$builder->join('t_unit', 't_unit.id = t_cmpny_flow.qntty_unit_id');
		$builder->join('t_costbenefit_temp', 't_costbenefit_temp.is_id = t_is_prj_details.id', 'left');
		$builder->where('t_is_prj_details.cmpny_to_id', $cmpny_id);
		$data = $builder->get()->getResultArray();
		return $data;
	}

	public function get_allocation_values($cmpny_id, $prjct_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_company_project');
		$builder->select('t_prcss.name as prcss_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name, t_cp_company_project.allocation_id as allocation_id, t_cp_company_project.prjct_id as project_id, t_cp_company_project.cmpny_id as company_id');
		$builder->join('t_cp_allocation', 't_cp_allocation.id = t_cp_company_project.allocation_id');
		$builder->join('t_flow', 't_flow.id = t_cp_allocation.flow_id');
		$builder->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
		$builder->join('t_cmpny_prcss', 't_cmpny_prcss.id = t_cp_allocation.prcss_id');
		$builder->join('t_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
		$builder->where('t_cp_company_project.prjct_id', $prjct_id);
		$builder->where('t_cp_company_project.cmpny_id', $cmpny_id);
		$builder->orderBy("t_prcss.name", "asc");
		$builder->orderBy("t_flow.name", "asc");
		$builder->orderBy("t_flow_type.name", "asc");
		return $builder->get()->getResultArray();
	}

	public function get_allocation_from_fname_pname_copy($flow_id, $allocation_id, $input_output)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_allocation');
		$builder->select('t_prcss.name as prcss_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name,amount,unit_amount,allocation_amount,error_amount,cost,unit_cost,allocation_cost,error_cost,env_impact,unit_env_impact,allocation_env_impact,error_ep');
		$builder->join('t_flow', 't_flow.id = t_cp_allocation.flow_id');
		$builder->join('t_flow_type', 't_flow_type.id = t_cp_allocation.flow_type_id');
		$builder->join('t_cmpny_prcss', 't_cmpny_prcss.id = t_cp_allocation.prcss_id');
		$builder->join('t_prcss', 't_prcss.id = t_cmpny_prcss.prcss_id');
		$builder->where('t_cp_allocation.id', $allocation_id);
		$builder->where('t_cp_allocation.flow_id', $flow_id);
		$builder->where('t_cp_allocation.flow_type_id', $input_output);
		return $builder->get()->getRowArray();
	}

	public function get_allocation_prcss_flow_id($allocation_id, $input_output)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_allocation');
		$builder->select('*');
		$builder->where('id', $allocation_id);
		$builder->where('flow_type_id', $input_output);
		return $builder->get()->getRowArray();
	}

	public function cp_is_candidate_control($allocation_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_is_candidate');
		$builder->select('*');
		$builder->where('allocation_id', $allocation_id);
		$query = $builder->get()->getRowArray();

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
		$db = db_connect();
		$builder = $db->table('t_cp_is_candidate');
		$builder->insert($is_candidate_array);
	}

	public function cp_is_candidate_update($is_candidate_array, $allocation_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_is_candidate');
		$builder->where('allocation_id', $allocation_id);
		$builder->replace($is_candidate_array);
	}

	public function get_is_candidate_active_position($allocation_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_is_candidate');
		$builder->select('active');
		$builder->where('allocation_id', $allocation_id);
		$query = $builder->get()->getRowArray();

		if (empty($query)) {
			return 0;
		} else {
			return $query['active'];
		}
	}

	public function insert_cp_scoping_file($cp_scoping_files)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_scoping_files');
		$builder->insert($cp_scoping_files);
	}

	//TODO: not sure it will work.
	public function delete_cp_scoping_file($cp_scoping_files)
	{
		$db = db_connect();
        $builder = $db->table('t_cp_scoping_files');
        $builder->delete($cp_scoping_files);
	}

	public function get_cp_scoping_files($project_id, $cmpny_id)
	{
		$db = db_connect();
        $builder = $db->table('t_cp_scoping_files');
        $builder->select('*');
        $builder->where('prjct_id', $project_id);
		$builder->where('cmpny_id', $cmpny_id);
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function search_result($search)
	{
		$db = db_connect();
        $builder = $db->table('t_cp_scoping_files');
		$builder->like('file_name', $search, 'both');
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function kpi_insert($kpi, $allocation_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cp_allocation');
		$builder->where('id', $allocation_id);
		$builder->replace($kpi);
	}

	public function can_consultant_prjct($user_id)
	{
		$db = db_connect();
        $builder = $db->table('t_prj_cnsltnt');
        $builder->select('prj_id');
        $builder->where('cnsltnt_id', $user_id);
		$builder->where('active', '1');
        $query = $builder->get()->getResultArray();
		if (!empty($query)) {
			return true;
		} else {
			return false;
		}
	}

	//allocation delete model
	public function delete_allocation($allocation_id, $project_id, $company_id)
	{
		$db = db_connect();
        $builder = $db->table('t_cp_allocation');
		$builder->where('id', $allocation_id);
        $builder->delete();

		$builder = $db->table('t_cp_company_project');
		$builder->where('allocation_id', $allocation_id);
		$builder->where('prjct_id', $project_id);
		$builder->where('cmpny_id', $company_id);
        $builder->delete();
	}

	//delete allocation by process id
	public function delete_allocation_prcssid($process_id)
	{
		$db = db_connect();
        $builder = $db->table('t_cp_allocation');
		$builder->where('prcss_id', $process_id);
        $builder->delete();
	}

}
