<?php 
namespace App\Models;

use CodeIgniter\Model;

class Process_model extends Model {

	public function __construct()
	{
		$db = db_connect();
	}

	public function get_cmpny_prcss_id_copy($cmpny_id,$prcss_id){
		$db->select('id');
		$db->from('t_cmpny_prcss');
		$db->where('cmpny_id',$cmpny_id);
		$db->where('prcss_id',$prcss_id);
		return $db->get()->row_array();
	}

	public function get_cmpny_prcss_from_id($cmpny_id,$prcss_id){
		$db->select('*');
		$db->from('t_cmpny_prcss');
		$db->where('cmpny_id',$cmpny_id);
		$db->where('prcss_id',$prcss_id);
		return $db->get()->row_array();
	}

	public function get_cmpny_prcss_from_rid($cmpny_id,$prcss_id){
		$db->select('*');
		$db->from('t_cmpny_prcss');
		$db->where('cmpny_id',$cmpny_id);
		$db->where('id',$prcss_id);
		return $db->get()->row_array();
	}

	//update comment of a process
	public function update_process_comment($cmpny_id,$prcss_id,$comment){
		$data = array(
               'comment' => $comment
            );
		$db->where('cmpny_id',$cmpny_id);
		$db->where('prcss_id',$prcss_id);
    $db->update('t_cmpny_prcss',$data); 
	}

	public function get_processfamily_list(){
		$db->select('*');
		$db->from('t_prcss_family');
		$query = $db->get();
		return $$query->getResultArray();
	}

	public function get_process(){
		$db->select('*');
	    $db->from('t_prcss');
	    $query = $db->get();
	    return $$query->getResultArray();
	}

	public function get_process_from_process_name($process_name){
		$db->select('*');
    	$db->from('t_prcss');
        $db->where('name',$process_name);
		$query = $db->get();
		return $query->row_array();
	}

	public function get_process_from_process_id($prcss_id){
		$db->select('*');
    	$db->from('t_prcss');
        $db->where('id',$prcss_id);
		$query = $db->get();
		return $query->row_array();
	}
	
	public function get_main_process(){
		$db->select('*');
		$db->from('t_prcss');
		//$db->where('mother_id',NULL);
		$db->where('active',1);
		$query = $db->get();
		return $$query->getResultArray();
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
			$db->insert('t_prcss',$data);
			return $db->insert_id();
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
			$db->insert('t_flow',$data);
			//echo "d";
			//exit;
			//echo $db->last_query();
			return $db->insert_id('t_flow_id_seq');
		}

	}

	public function get_process_from_motherID($mother_id){
		$db->select('*');
	    $db->from('t_prcss');
	    $db->where('mother_id',$mother_id);
	    $db->where('active',1);
	    $query = $db->get();
	    return $$query->getResultArray();
	}

	public function cmpny_flow_prcss($data){
		$db->insert('t_cmpny_flow_prcss',$data);
	}

	public function cmpny_prcss($data){
		$db->insert('t_cmpny_prcss',$data);
		return $db->insert_id();
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
		$db->select('id');
	    $db->from('t_cmpny_prcss');
	    $db->where('cmpny_id',$cmpny_id);
	    $db->where('prcss_id',$prcss_id);
	    $query = $db->get()->row_array();
	    if(empty($query))
	    	return false;
	    else
	    	return $query;
	}

	public function can_write_cmpny_flow_prcss($cmpny_flow_id,$cmpny_prcss_id){
		$db->select('*');
    $db->from('t_cmpny_flow_prcss');
    $db->where('cmpny_flow_id',$cmpny_flow_id);
    $db->where('cmpny_prcss_id',$cmpny_prcss_id);
    $query = $db->get()->row_array();
    if(empty($query)){
			return true;
		}
		return false;
	}
	public function cmpny_flow_prcss_id_list($id){
		$db->select('cmpny_prcss_id');
	    $db->from('t_cmpny_flow_prcss');
	    $db->where('cmpny_flow_id',$id);
	    $query = $db->get();
	    return $$query->getResultArray();
	}

	public function delete_cmpny_flow_process($cmpny_flow_id){
		$db->where('cmpny_flow_id', $cmpny_flow_id);
    	$db->delete('t_cmpny_flow_prcss'); 
	}

	public function delete_cmpny_process($cmpny_prcss_id){
		$db->where('id', $cmpny_prcss_id);
    	$db->delete('t_cmpny_prcss'); 
	}
	public function still_exist_this_cmpny_prcss($cmpny_prcss_id){
		$db->select('*');
	    $db->from('t_cmpny_flow_prcss');
	    $db->where('cmpny_prcss_id',$cmpny_prcss_id);
	    $query = $db->get()->row_array();
	    if(empty($query))
	    	return false;
	    else
	    	return true;
	}

	public function delete_company_flow_prcss($cmpny_prcss_id,$cmpny_flow_id){
		$db->where('cmpny_prcss_id', $cmpny_prcss_id);
		$db->where('cmpny_flow_id', $cmpny_flow_id);
		$db->delete('t_cmpny_flow_prcss'); 
	}

	public function delete_cmpny_prcss_eqpmnt_type($cmpny_prcss_id){
		$db->where('cmpny_prcss_id',$cmpny_prcss_id);
		$db->delete('t_cmpny_prcss_eqpmnt_type');
	}

	public function delete_cmpny_prcss($company_id){
		$db->where('cmpny_id',$company_id);
		$db->delete('t_cmpny_prcss');
	}

	public function get_cmpny_prcss_id($cmpny_id){
		$db->select('id');
		$db->from('t_cmpny_prcss');
		$db->where('cmpny_id',$cmpny_id);
		$query = $db->get()->result_array();
		return $query;
	}

	public function delete_cmpny_eqpmnt($companyID){
		$db->where('cmpny_id',$companyID);
		$db->delete('t_cmpny_eqpmnt');
	}

	public function update_cmpny_flow_prcss($companyID,$process_id,$cmpny_prcss){
		$db->where('t_cmpny_prcss.cmpny_id',$companyID);   
    $db->where('t_cmpny_prcss.id',$process_id);   
    $db->update('t_cmpny_prcss',$cmpny_prcss); 
	}
}
?>