<?php

namespace App\Controllers;

class Isscoping extends BaseController
{

    public function __construct()
    {
        parent::__construct();
        $this->load->model('company_model');
        $this->config->set_item('language', $session->get('site_lang'));

    }

    public function index()
    {
        //print_r($session->get['user_in']);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != '3') {
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
        //print_r($session->get['user_in']);
        $data['userID'] = $session->get['user_in']['id'];

        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != '3') {
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
        //print_r($session->get['user_in']);
        //print_r($session->get);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $project_id = $session->get('project_id');

        $data['companies'] = $this->company_model->get_project_companies($project_id);
        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        $data['language']   = $session->get('site_lang');
        $this->load->view('template/header');
        $this->load->view('isscoping/autoprojectbaseMDF', $data);
        $this->load->view('template/footer');
    }

    public function autoprjbaseMDFTest()
    {
        //print_r('zeynel');
        //print_r($session->get['user_in']);
        //print_r($session->get);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        $this->load->view('template/header');
        $this->load->view('isscoping/autoprojectbaseMDF_test', $data);
        $this->load->view('template/footer');
    }

    public function autoprjbase()
    {
        //print_r('zeynel');
        //print_r($session->get['user_in']);
        //print_r($session->get);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        $this->load->view('template/header');
        $this->load->view('isscoping/autoprojectbase', $data);
        $this->load->view('template/footer');
    }

    public function prjbaseMDF()
    {
        //print_r($session->get);
        //print_r($session->get['user_in']['id']);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }


        $project_id = $session->get('project_id');

        $data['companies'] = $this->company_model->get_project_companies($project_id);
        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        $data['language']   = $session->get('site_lang');
        $this->load->view('template/header');
        $this->load->view('isscoping/projectbaseMDF', $data);
        $this->load->view('template/footer');
    }

    public function prjbase()
    {
        //print_r($session->get);
        //print_r($session->get['user_in']['id']);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
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
        //print_r($session->get['user_in']);
        //print_r($session->get);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }


        $project_id = $session->get('project_id');

        $data['companies'] = $this->company_model->get_project_companies($project_id);
        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        $data['language']   = $session->get('site_lang');
        $this->load->view('template/header');
        $this->load->view('isscoping/isscenarios', $data);
        $this->load->view('template/footer');
    }

    public function isscenariosCns()
    {
        //print_r('zeynel');
        //print_r($session->get['user_in']);
        //print_r($session->get);
        if (isset($session->get['user_in'])) {
            if (empty($session->get['user_in'])) {
                redirect(base_url('login'), 'refresh');
            }
        } else {
            redirect(base_url('login'), 'refresh');
        }

        if (isset($session->get['project_id'])) {
            if ($session->get['project_id'] == null || $session->get['project_id'] == '') {
                redirect(base_url('projects'), 'refresh');
            }
        } else {
            redirect(base_url('projects'), 'refresh');
        }

        if (isset($session->get['user_in']['role_id'])) {
            if (($session->get['user_in']['role_id'] == null || $session->get['user_in']['role_id'] == '')
                || $session->get['user_in']['role_id'] != 1) {
                redirect(base_url('company'), 'refresh');
            }
        } else {
            redirect(base_url('company'), 'refresh');
        }

        
        $project_id = $session->get('project_id');

        $data['companies'] = $this->company_model->get_project_companies($project_id);
        $data['userID']     = $session->get['user_in']['id'];
        $data['project_id'] = $session->get['project_id'];
        $data['language']   = $session->get('site_lang');
        $this->load->view('template/header');
        $this->load->view('isscoping/isscenariosCns', $data);
        $this->load->view('template/footer');
    }

}
