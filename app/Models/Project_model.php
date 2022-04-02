<?php
namespace App\Models;

use CodeIgniter\Model;

class Project_model extends Model
{
    
    public function create_project($project)
    {
        $db->insert('t_prj', $project);
        return $db->insert_id();
    }

    public function update_project($project, $id)
    {
        $db->where('id', $id);
        $db->update('t_prj', $project);
    }

    public function get_active_project_status()
    {
        $db->select('*');
        $db->from('t_prj_status');
        $db->where('active', 1);
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function insert_project_company($prj_cmpny)
    {
        $db->insert('t_prj_cmpny', $prj_cmpny);
    }
    public function insert_project_consultant($prj_cnsltnt)
    {
        $db->insert('t_prj_cnsltnt', $prj_cnsltnt);
    }
    public function insert_project_contact_person($prj_cntct_prsnl)
    {
        $db->insert('t_prj_cntct_prsnl', $prj_cntct_prsnl);
    }

    public function get_projects()
    {
        $db = db_connect();
        $builder = $db->table('t_prj');
        $builder->select('*');
        $builder->orderBy('name', 'asc');
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function get_consultant_projects($cons_id)
    {

        $db = db_connect();
        $builder = $db->table('t_prj');
        $builder->select('t_prj.id, t_prj.name, t_prj.description, t_prj.latitude, t_prj.longitude');
        $builder->join('t_prj_cnsltnt', 't_prj.id = t_prj_cnsltnt.prj_id');
        $builder->join('t_prj_cntct_prsnl', 't_prj.id = t_prj_cntct_prsnl.prj_id');
        $builder->where('t_prj_cnsltnt.cnsltnt_id', $cons_id);
        $builder->orWhere('t_prj_cntct_prsnl.usr_id', $cons_id);
        $builder->groupBy("t_prj.id");
        $builder->orderBy("t_prj.name");
        return $builder->get()->getResultArray();

    }

    public function get_project($prj_id)
    {
        $db->select("*");
        $db->from('t_prj');
        $db->where('id', $prj_id);
        $query = $db->get();
        return $query->row_array();
    }

    public function get_status($prj_id)
    {
        $db->select('t_prj_status.name');
        $db->from('t_prj_status');
        $db->join('t_prj', 't_prj.status_id = t_prj_status.id');
        $db->where('t_prj.id', $prj_id);
        $query = $db->get();
        return $query->row_array();
    }

    public function get_prj_consaltnt($prj_id)
    {
        $db->select('t_user.name,t_user.surname,t_user.id,t_user.user_name');
        $db->from('t_user');
        $db->join('t_prj_cnsltnt', 't_prj_cnsltnt.cnsltnt_id = t_user.id');
        $db->where('t_prj_cnsltnt.prj_id', $prj_id);
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function get_prj_companies($prj_id)
    {
        $db->select('t_cmpny.name,t_cmpny.id,latitude,longitude');
        $db->from('t_cmpny');
        $db->join('t_prj_cmpny', 't_prj_cmpny.cmpny_id = t_cmpny.id');
        $db->where('t_prj_cmpny.prj_id', $prj_id);
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function deneme_json_2($prj_id)
    {
        $db->select('t_cmpny.name as text,t_cmpny.id as id');
        $db->from('t_cmpny');
        $db->join('t_prj_cmpny', 't_prj_cmpny.cmpny_id = t_cmpny.id');
        $db->where('t_prj_cmpny.prj_id', $prj_id);
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function get_prj_cntct_prsnl($prj_id)
    {
        $db->select('t_user.name,t_user.surname,t_user.id,t_user.user_name');
        $db->from('t_user');
        $db->join('t_prj_cntct_prsnl', 't_prj_cntct_prsnl.usr_id = t_user.id');
        $db->where('t_prj_cntct_prsnl.prj_id', $prj_id);
        $query = $db->get();
        return $$query->getResultArray();
    }
    public function remove_company_from_project($projID)
    {
        $db->delete('t_prj_cmpny', array('prj_id' => $projID));
    }

    public function remove_consultant_from_project($projID)
    {
        $db->delete('t_prj_cnsltnt', array('prj_id' => $projID));
    }

    public function remove_contactuser_from_project($projID)
    {
        $db->delete('t_prj_cntct_prsnl', array('prj_id' => $projID));
    }

    public function can_update_project_information($user_id, $project_id)
    {
        
        $db = db_connect();
        $builder = $db->table('t_prj_cnsltnt');
        $builder->select('t_prj_cnsltnt.cnsltnt_id as cnsltnt_id, t_prj_cntct_prsnl.usr_id as cnsltnt_id2');
        $builder->join('t_prj_cntct_prsnl', 't_prj_cntct_prsnl.prj_id = t_prj_cnsltnt.prj_id', 'left');
        $builder->where('t_prj_cnsltnt.prj_id', $project_id);
        $query = $builder->get()->getResultArray();
        foreach ($query as $cnsltnt) {
            if ($cnsltnt['cnsltnt_id'] == $user_id or $cnsltnt['cnsltnt_id2'] == $user_id) {
                return true;
            }
        }
        return false;

    }

    public function have_project_name($project_id, $project_name)
    {
        $db->select('id');
        $db->from('t_prj');
        $db->where('name', $project_name);
        $query = $db->get()->result_array();
        if (empty($query)) {
            return true;
        } else {
            foreach ($query as $variable) {
                if ($variable['id'] != $project_id) {
                    return false;
                }
            }
            return true;
        }
    }
    //project delete model
    public function delete_project($project_id)
    {
        //deletes the linked consultants
        $db->where('prj_id', $project_id);
        $db->delete('t_prj_cnsltnt');

        //deletes the linked companies
        $db->where('prj_id', $project_id);
        $db->delete('t_prj_cmpny');        

        //deletes the project
        $db->where('id', $project_id);
        $db->delete('t_prj');
    }

}
