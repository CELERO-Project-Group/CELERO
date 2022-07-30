<?php 
namespace App\Models;

use CodeIgniter\Model;

class Process_model extends Model {

	public function get_cmpny_prcss_id_copy($cmpny_id,$prcss_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
        $builder->select('id');
        $builder->where('cmpny_id',$cmpny_id);
		$builder->where('prcss_id',$prcss_id);
        $query = $builder->get();
        return $query->getRowArray();
	}

	public function get_cmpny_prcss_from_id($cmpny_id,$prcss_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
        $builder->select('*');
        $builder->where('cmpny_id',$cmpny_id);
		$builder->where('prcss_id',$prcss_id);
        $query = $builder->get();
        return $query->getRowArray();
	}

	public function get_cmpny_prcss_from_rid($cmpny_id,$prcss_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
        $builder->select('*');
        $builder->where('cmpny_id',$cmpny_id);
		$builder->where('id',$prcss_id);
        $query = $builder->get();
        return $query->getRowArray();
	}

	//update comment of a process
	public function update_process_comment($cmpny_id,$prcss_id,$comment){
		$data = array(
               'comment' => $comment
            );
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
        $builder->where('cmpny_id',$cmpny_id);
		$builder->where('prcss_id',$prcss_id);
        $builder->update($data);
	}

	public function get_processfamily_list(){
		$db = db_connect();
        $builder = $db->table('t_prcss_family');
        $builder->select("*");
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function get_process(){
		$db = db_connect();
        $builder = $db->table('t_prcss');
        $builder->select("*");
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function get_process_from_process_name($process_name){
		$db = db_connect();
        $builder = $db->table('t_prcss');
        $builder->select('*');
        $builder->where('name',$process_name);
        $query = $builder->get();
        return $query->getRowArray();
	}

	public function get_process_from_process_id($prcss_id){
		$db = db_connect();
        $builder = $db->table('t_prcss');
        $builder->select('*');
        $builder->where('id',$prcss_id);
        $query = $builder->get();
        return $query->getRowArray();
	}
	
	public function get_main_process(){
		$db = db_connect();
        $builder = $db->table('t_prcss');
        $builder->select("*");
		$builder->where('active',1);
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function is_new_process($process_id,$processfamilyID = false){
		if(is_numeric($process_id)){
			return $process_id;
		}
		else{
			$data = array(
				'name' => $process_id,
				'prcss_family_id' => $processfamilyID,
				'active' => 1,
				'layer' => 1
			);
			$db = db_connect();
			$builder = $db->table('t_prcss');
			$builder->insert($data);
			return $db->insertID();
		}

	}

	public function is_new_flow($flowID,$flowfamilyID = false){
		if(is_numeric($flowID)){
			return $flowID;
		}
		else{
			$data = array(
				'name' => $flowID,
				'flow_family_id' => $flowfamilyID,
				'active' => 1,
			);
			$db = db_connect();
			$builder = $db->table('t_flow');
			$builder->insert($data);
			return $db->insertID('t_flow_id_seq');
		}

	}

	public function get_process_from_motherID($mother_id){
		$db = db_connect();
        $builder = $db->table('t_prcss');
        $builder->select('*');
		$builder->where('mother_id',$mother_id);
	    $builder->where('active',1);
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function cmpny_flow_prcss($data){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_prcss');
        $builder->insert($data);
	}

	public function cmpny_prcss($data){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
        $builder->insert($data);
        return $db->insertID();
	}

	public function get_cmpny_flow_prcss($id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_prcss');
        $builder->select('t_cmpny_prcss.comment,t_cmpny_prcss.max_rate_util,t_cmpny_prcss.typ_rate_util,t_cmpny_prcss.min_rate_util,t_cmpny_flow.id as company_flow_id, t_flow.name as flowname, t_prcss.name as prcessname,
		unit1.name as minrateu,unit2.name as typrateu,unit3.name as maxrateu,
		t_flow_type.name as flow_type_name, t_prcss.id as prcessid, t_cmpny_prcss.id as company_process_id, 
		t_cmpny_flow.flow_id as flow_id , t_cmpny_flow.flow_type_id as flow_type_id');
        $builder->join('t_cmpny_flow','t_cmpny_flow.id = t_cmpny_flow_prcss.cmpny_flow_id');
		$builder->join('t_flow','t_flow.id = t_cmpny_flow.flow_id');
		$builder->join('t_flow_family','t_flow_family.id = t_flow.flow_family_id','left');
		$builder->join('t_cmpny_prcss','t_cmpny_prcss.id = t_cmpny_flow_prcss.cmpny_prcss_id');
		$builder->join('t_unit as unit1','unit1.id = t_cmpny_prcss.min_rate_util_unit','left');
		$builder->join('t_unit as unit2','unit2.id = t_cmpny_prcss.typ_rate_util_unit','left');
		$builder->join('t_unit as unit3','unit3.id = t_cmpny_prcss.max_rate_util_unit','left');
		$builder->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id');
		$builder->join('t_prcss','t_prcss.id = t_cmpny_prcss.prcss_id');
		$builder->where('t_cmpny_flow.cmpny_id',$id);
		$builder->orderBy("t_prcss.name", "asc"); 
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function can_write_cmpny_prcss($cmpny_id,$prcss_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
        $builder->select('id');
        $builder->where('cmpny_id',$cmpny_id);
	    $builder->where('prcss_id',$prcss_id);
        $query = $builder->get();
	    if(empty($query))
	    	return false;
	    else
	    	return $query;
	}

	public function can_write_cmpny_flow_prcss($cmpny_flow_id,$cmpny_prcss_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_prcss');
        $builder->select('*');
		$builder->where('cmpny_flow_id',$cmpny_flow_id);
		$builder->where('cmpny_prcss_id',$cmpny_prcss_id);
        $query = $builder->get();
		if(empty($query)){
			return true;
		}
		return false;
	}

	public function cmpny_flow_prcss_id_list($id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_prcss');
        $builder->select('cmpny_prcss_id');
		$builder->where('cmpny_flow_id',$id);
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function delete_cmpny_flow_process($cmpny_flow_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_prcss');
		$builder->where('cmpny_flow_id', $cmpny_flow_id);
        $builder->delete();
	}

	public function delete_cmpny_process($cmpny_prcss_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
		$builder->where('id', $cmpny_prcss_id);
        $builder->delete();
	}

	public function still_exist_this_cmpny_prcss($cmpny_prcss_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_prcss');
        $builder->select("*");
	    $builder->where('cmpny_prcss_id',$cmpny_prcss_id);
        $query = $builder->get()->getRowArray();
	    if(empty($query))
	    	return false;
	    else
	    	return true;
	}

	public function delete_company_flow_prcss($cmpny_prcss_id,$cmpny_flow_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_prcss');
		$builder->where('cmpny_prcss_id', $cmpny_prcss_id);
		$builder->where('cmpny_flow_id', $cmpny_flow_id);
        $builder->delete();
	}

	public function delete_cmpny_prcss_eqpmnt_type($cmpny_prcss_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss_eqpmnt_type');
		$builder->where('cmpny_prcss_id', $cmpny_prcss_id);
        $builder->delete();
	}

	public function delete_cmpny_prcss($company_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
		$builder->where('cmpny_id',$company_id);
        $builder->delete();
	}

	public function get_cmpny_prcss_id($cmpny_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
        $builder->select('id');
		$builder->where('cmpny_id',$cmpny_id);
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function delete_cmpny_eqpmnt($companyID){
		$db = db_connect();
        $builder = $db->table('t_cmpny_eqpmnt');
		$builder->where('cmpny_id',$companyID);
        $builder->delete();
	}

	public function update_cmpny_flow_prcss($companyID,$process_id,$cmpny_prcss){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
		$builder->where('t_cmpny_prcss.cmpny_id',$companyID);   
    	$builder->where('t_cmpny_prcss.id',$process_id);   
        $builder->replace($cmpny_prcss);
	}
}
?>