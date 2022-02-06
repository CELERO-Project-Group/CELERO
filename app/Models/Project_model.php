<?php
namespace App\Models;

use CodeIgniter\Model;

class Project_model extends Model
{

    public function __construct()
    {
        $this->load->database();
    }
    public function create_project($project)
    {
        $this->db->insert('t_prj', $project);
        return $this->db->insert_id();
    }

    public function update_project($project, $id)
    {
        $this->db->where('id', $id);
        $this->db->update('t_prj', $project);
    }

    public function get_active_project_status()
    {
        $this->db->select('*');
        $this->db->from('t_prj_status');
        $this->db->where('active', 1);
        $query = $this->db->get();
        return $query->result_array();
    }

    public function insert_project_company($prj_cmpny)
    {
        $this->db->insert('t_prj_cmpny', $prj_cmpny);
    }
    public function insert_project_consultant($prj_cnsltnt)
    {
        $this->db->insert('t_prj_cnsltnt', $prj_cnsltnt);
    }
    public function insert_project_contact_person($prj_cntct_prsnl)
    {
        $this->db->insert('t_prj_cntct_prsnl', $prj_cntct_prsnl);
    }

    public function get_projects()
    {
        $this->db->select("*");
        $this->db->from('t_prj');
        $this->db->order_by("name", "asc");
        $query = $this->db->get();
        return $query->result_array();
    }

    public function get_consultant_projects($cons_id)
    {
        $this->db->select("t_prj.id, t_prj.name, t_prj.description, t_prj.latitude, t_prj.longitude");
        $this->db->from('t_prj');
        $this->db->join('t_prj_cnsltnt', 't_prj.id = t_prj_cnsltnt.prj_id');
        $this->db->join('t_prj_cntct_prsnl', 't_prj.id = t_prj_cntct_prsnl.prj_id');
        $this->db->where('t_prj_cnsltnt.cnsltnt_id', $cons_id);
        $this->db->or_where('t_prj_cntct_prsnl.usr_id', $cons_id);
        $this->db->group_by("t_prj.id");
        $this->db->order_by("t_prj.name");
        $query = $this->db->get();
        return $query->result_array();
    }

    public function get_project($prj_id)
    {
        $this->db->select("*");
        $this->db->from('t_prj');
        $this->db->where('id', $prj_id);
        $query = $this->db->get();
        return $query->row_array();
    }

    public function get_status($prj_id)
    {
        $this->db->select('t_prj_status.name');
        $this->db->from('t_prj_status');
        $this->db->join('t_prj', 't_prj.status_id = t_prj_status.id');
        $this->db->where('t_prj.id', $prj_id);
        $query = $this->db->get();
        return $query->row_array();
    }

    public function get_prj_consaltnt($prj_id)
    {
        $this->db->select('t_user.name,t_user.surname,t_user.id,t_user.user_name');
        $this->db->from('t_user');
        $this->db->join('t_prj_cnsltnt', 't_prj_cnsltnt.cnsltnt_id = t_user.id');
        $this->db->where('t_prj_cnsltnt.prj_id', $prj_id);
        $query = $this->db->get();
        return $query->result_array();
    }

    public function get_prj_companies($prj_id)
    {
        $this->db->select('t_cmpny.name,t_cmpny.id,latitude,longitude');
        $this->db->from('t_cmpny');
        $this->db->join('t_prj_cmpny', 't_prj_cmpny.cmpny_id = t_cmpny.id');
        $this->db->where('t_prj_cmpny.prj_id', $prj_id);
        $query = $this->db->get();
        return $query->result_array();
    }

    public function deneme_json_2($prj_id)
    {
        $this->db->select('t_cmpny.name as text,t_cmpny.id as id');
        $this->db->from('t_cmpny');
        $this->db->join('t_prj_cmpny', 't_prj_cmpny.cmpny_id = t_cmpny.id');
        $this->db->where('t_prj_cmpny.prj_id', $prj_id);
        $query = $this->db->get();
        return $query->result_array();
    }

    public function get_prj_cntct_prsnl($prj_id)
    {
        $this->db->select('t_user.name,t_user.surname,t_user.id,t_user.user_name');
        $this->db->from('t_user');
        $this->db->join('t_prj_cntct_prsnl', 't_prj_cntct_prsnl.usr_id = t_user.id');
        $this->db->where('t_prj_cntct_prsnl.prj_id', $prj_id);
        $query = $this->db->get();
        return $query->result_array();
    }
    public function remove_company_from_project($projID)
    {
        $this->db->delete('t_prj_cmpny', array('prj_id' => $projID));
    }

    public function remove_consultant_from_project($projID)
    {
        $this->db->delete('t_prj_cnsltnt', array('prj_id' => $projID));
    }

    public function remove_contactuser_from_project($projID)
    {
        $this->db->delete('t_prj_cntct_prsnl', array('prj_id' => $projID));
    }

    public function can_update_project_information($user_id, $project_id)
    {
        $this->db->select('t_prj_cnsltnt.cnsltnt_id as cnsltnt_id, t_prj_cntct_prsnl.usr_id as cnsltnt_id2');
        $this->db->from('t_prj_cnsltnt');
        $this->db->join('t_prj_cntct_prsnl', 't_prj_cntct_prsnl.prj_id = t_prj_cnsltnt.prj_id', 'left');
        $this->db->where('t_prj_cnsltnt.prj_id', $project_id);
        $query = $this->db->get()->result_array();
        foreach ($query as $cnsltnt) {
            if ($cnsltnt['cnsltnt_id'] == $user_id or $cnsltnt['cnsltnt_id2'] == $user_id) {
                return true;
            }
        }
        return false;
    }

    public function have_project_name($project_id, $project_name)
    {
        $this->db->select('id');
        $this->db->from('t_prj');
        $this->db->where('name', $project_name);
        $query = $this->db->get()->result_array();
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
        $this->db->where('prj_id', $project_id);
        $this->db->delete('t_prj_cnsltnt');

        //deletes the linked companies
        $this->db->where('prj_id', $project_id);
        $this->db->delete('t_prj_cmpny');        

        //deletes the project
        $this->db->where('id', $project_id);
        $this->db->delete('t_prj');
    }

}
