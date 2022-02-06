<?php

namespace App\Controllers;

class Isscoping extends BaseController
{

    public function __construct()
    {
        parent::__construct();
        $this->load->model('company_model');
        $this->config->set_item('language', $this->session->userdata('site_lang'));

    }

    public function index()
    {
        //print_r($this->session->userdata['user_in']);
        if (isset($this->session->userdata['user_in'])) {
            if (empty($this->session->userdata['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($this->session->userdata['user_in']['role_id'])) {
            if (($this->session->userdata['user_in']['role_id'] == null || $this->session->userdata['user_in']['role_id'] == '')
                || $this->session->userdata['user_in']['role_id'] != '3') {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $this->load->view('template/header');
        $this->load->view('isscoping/index');
        $this->load->view('template/footer');
    }

    public function auto()
    {
        //print_r($this->session->userdata['user_in']);
        $data['userID'] = $this->session->userdata['user_in']['id'];

        if (isset($this->session->userdata['user_in'])) {
            if (empty($this->session->userdata['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($this->session->userdata['user_in']['role_id'])) {
            if (($this->session->userdata['user_in']['role_id'] == null || $this->session->userdata['user_in']['role_id'] == '')
                || $this->session->userdata['user_in']['role_id'] != '3') {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $this->load->view('template/header');
        $this->load->view('isscoping/auto', $data);
        $this->load->view('template/footer');
    }

    public function autoprjbaseMDF()
    {
        //print_r('zeynel');
        //print_r($this->session->userdata['user_in']);
        //print_r($this->session->userdata);
        if (isset($this->session->userdata['user_in'])) {
            if (empty($this->session->userdata['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($this->session->userdata['project_id'])) {
            if ($this->session->userdata['project_id'] == null || $this->session->userdata['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($this->session->userdata['user_in']['role_id'])) {
            if (($this->session->userdata['user_in']['role_id'] == null || $this->session->userdata['user_in']['role_id'] == '')
                || $this->session->userdata['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $project_id = $this->session->userdata('project_id');

        $data['companies'] = $this->company_model->get_project_companies($project_id);
        $data['userID']     = $this->session->userdata['user_in']['id'];
        $data['project_id'] = $this->session->userdata['project_id'];
        $data['language']   = $this->session->userdata('site_lang');
        $this->load->view('template/header');
        $this->load->view('isscoping/autoprojectbaseMDF', $data);
        $this->load->view('template/footer');
    }

    public function autoprjbaseMDFTest()
    {
        //print_r('zeynel');
        //print_r($this->session->userdata['user_in']);
        //print_r($this->session->userdata);
        if (isset($this->session->userdata['user_in'])) {
            if (empty($this->session->userdata['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($this->session->userdata['project_id'])) {
            if ($this->session->userdata['project_id'] == null || $this->session->userdata['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($this->session->userdata['user_in']['role_id'])) {
            if (($this->session->userdata['user_in']['role_id'] == null || $this->session->userdata['user_in']['role_id'] == '')
                || $this->session->userdata['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $data['userID']     = $this->session->userdata['user_in']['id'];
        $data['project_id'] = $this->session->userdata['project_id'];
        $this->load->view('template/header');
        $this->load->view('isscoping/autoprojectbaseMDF_test', $data);
        $this->load->view('template/footer');
    }

    public function autoprjbase()
    {
        //print_r('zeynel');
        //print_r($this->session->userdata['user_in']);
        //print_r($this->session->userdata);
        if (isset($this->session->userdata['user_in'])) {
            if (empty($this->session->userdata['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($this->session->userdata['project_id'])) {
            if ($this->session->userdata['project_id'] == null || $this->session->userdata['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($this->session->userdata['user_in']['role_id'])) {
            if (($this->session->userdata['user_in']['role_id'] == null || $this->session->userdata['user_in']['role_id'] == '')
                || $this->session->userdata['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $data['userID']     = $this->session->userdata['user_in']['id'];
        $data['project_id'] = $this->session->userdata['project_id'];
        $this->load->view('template/header');
        $this->load->view('isscoping/autoprojectbase', $data);
        $this->load->view('template/footer');
    }

    public function prjbaseMDF()
    {
        //print_r($this->session->userdata);
        //print_r($this->session->userdata['user_in']['id']);
        if (isset($this->session->userdata['user_in'])) {
            if (empty($this->session->userdata['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($this->session->userdata['project_id'])) {
            if ($this->session->userdata['project_id'] == null || $this->session->userdata['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($this->session->userdata['user_in']['role_id'])) {
            if (($this->session->userdata['user_in']['role_id'] == null || $this->session->userdata['user_in']['role_id'] == '')
                || $this->session->userdata['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }


        $project_id = $this->session->userdata('project_id');

        $data['companies'] = $this->company_model->get_project_companies($project_id);
        $data['userID']     = $this->session->userdata['user_in']['id'];
        $data['project_id'] = $this->session->userdata['project_id'];
        $data['language']   = $this->session->userdata('site_lang');
        $this->load->view('template/header');
        $this->load->view('isscoping/projectbaseMDF', $data);
        $this->load->view('template/footer');
    }

    public function prjbase()
    {
        //print_r($this->session->userdata);
        //print_r($this->session->userdata['user_in']['id']);
        if (isset($this->session->userdata['user_in'])) {
            if (empty($this->session->userdata['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($this->session->userdata['project_id'])) {
            if ($this->session->userdata['project_id'] == null || $this->session->userdata['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($this->session->userdata['user_in']['role_id'])) {
            if (($this->session->userdata['user_in']['role_id'] == null || $this->session->userdata['user_in']['role_id'] == '')
                || $this->session->userdata['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $data['userID']     = $this->session->userdata['user_in']['id'];
        $data['project_id'] = $this->session->userdata['project_id'];
        $this->load->view('template/header');
        $this->load->view('isscoping/projectbase', $data);
        $this->load->view('template/footer');
    }

    public function tooltip()
    {
        //$this->load->view('template/header');
        $this->load->view('isscoping/tooltip');
        //$this->load->view('template/footer');
    }

    public function tooltipscenarios()
    {
        //$this->load->view('template/header');
        $this->load->view('isscoping/tooltipscenarios');
        //$this->load->view('template/footer');
    }

    public function isscenarios()
    {
        //print_r('zeynel');
        //print_r($this->session->userdata['user_in']);
        //print_r($this->session->userdata);
        if (isset($this->session->userdata['user_in'])) {
            if (empty($this->session->userdata['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($this->session->userdata['project_id'])) {
            if ($this->session->userdata['project_id'] == null || $this->session->userdata['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($this->session->userdata['user_in']['role_id'])) {
            if (($this->session->userdata['user_in']['role_id'] == null || $this->session->userdata['user_in']['role_id'] == '')
                || $this->session->userdata['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }


        $project_id = $this->session->userdata('project_id');

        $data['companies'] = $this->company_model->get_project_companies($project_id);
        $data['userID']     = $this->session->userdata['user_in']['id'];
        $data['project_id'] = $this->session->userdata['project_id'];
        $data['language']   = $this->session->userdata('site_lang');
        $this->load->view('template/header');
        $this->load->view('isscoping/isscenarios', $data);
        $this->load->view('template/footer');
    }

    public function isscenariosCns()
    {
        //print_r('zeynel');
        //print_r($this->session->userdata['user_in']);
        //print_r($this->session->userdata);
        if (isset($this->session->userdata['user_in'])) {
            if (empty($this->session->userdata['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($this->session->userdata['project_id'])) {
            if ($this->session->userdata['project_id'] == null || $this->session->userdata['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($this->session->userdata['user_in']['role_id'])) {
            if (($this->session->userdata['user_in']['role_id'] == null || $this->session->userdata['user_in']['role_id'] == '')
                || $this->session->userdata['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        
        $project_id = $this->session->userdata('project_id');

        $data['companies'] = $this->company_model->get_project_companies($project_id);
        $data['userID']     = $this->session->userdata['user_in']['id'];
        $data['project_id'] = $this->session->userdata['project_id'];
        $data['language']   = $this->session->userdata('site_lang');
        $this->load->view('template/header');
        $this->load->view('isscoping/isscenariosCns', $data);
        $this->load->view('template/footer');
    }

}
