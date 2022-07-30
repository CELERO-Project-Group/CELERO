<?php

namespace App\Controllers;

class Password extends BaseController {

	public function send_email_for_change_pass(){

		$this->form_validation->set_rules('old_pass', 'Old Password', 'trim|xss_clean|required');
		$this->form_validation->set_rules('new_pass', 'New Password', 'trim|xss_clean|required|callback_password_check');
		$this->form_validation->set_rules('new_pass_again', 'New Password(Again)', 'trim|xss_clean|required');
		if ($this->form_validation->run() !== FALSE){
			$user = $session->get('user_in');
			$pass = md5($this->input->post('old_pass'));
			if($password_model->do_similar_pass($user['id'],$pass)){
				$data = array(
						'psswrd' => md5($this->input->post('new_pass'))
					);
				$password_model->change_pass($user['id'],$data);
				redirect('send_email_for_change_pass','refresh');
			}
		}
		echo view('template/header');
		echo view('password/send_email_for_change_pass');
		echo view('template/footer');
	}

	public function change_pass($rnd_str){

		$random = $rnd_str = $this->uri->segment(2);

		if($password_model->click_control($random) == true){

			$this->form_validation->set_rules('old_pass', 'Old Password', 'trim|xss_clean|required');
			$this->form_validation->set_rules('new_pass', 'New Password', 'trim|xss_clean|required|callback_password_check');
			$this->form_validation->set_rules('new_pass_again', 'New Password Again', 'trim|xss_clean|required');

			if ($this->form_validation->run() !== FALSE){

				$user_id = $password_model->get_user_id($random);

				$old_pass = $this->input->post('old_pass');
				$new_pass = $this->input->post('new_pass');
				if($password_model->do_similar_pass($user_id,md5($old_pass)) == true){
					$control = array(
							'psswrd' => md5($new_pass)
						);
					$password_model->change_pass($user_id,$control);
				}

				$message = 'Your password has been changed. Your new password is: '.$new_pass;
				$email = $password_model->get_email($user_id);

				$send_email = array(
						'message' => $message,
						'email' => $email
					);
				$mailCheck = $this->sendMAil($send_email);

				$rnd_str = array(
					'random_string' => null,
					'click_control' => 0
				);
				$password_model->set_random_string_zero($random,$rnd_str);

				redirect('login','refresh');
			}

			$data = array(
				'random_string' => $random
			);

			echo view('template/header');
			echo view('password/change_pass',$data);
			echo view('template/footer');
		}
		else{
			redirect('','refresh');
		}
	}

	public function new_password_email(){
		$this->form_validation->set_rules('email', 'E-mail', 'trim|xss_clean|required');

		if ($this->form_validation->run() !== FALSE){

			$email = $this->input->post('email');

			$user_id = $password_model->get_id($email);

			$random_str = $this->generateRandomString();
			$asd = base_url("new_password/".$random_str);

			$message = '<a href='.$asd.'>Change Password</a>';

			$rnd_str = array(
					'random_string' => $random_str,
					'click_control' => 1
				);
			$password_model->set_random_string($user_id,$rnd_str);

			$data = array(
					'message' => $message,
					'email' => $email
				);
			$this->sendMAil($data);
			redirect('','refresh');
		}
		echo view('template/header');
		echo view('password/new_password_email');
		echo view('template/footer');
	}

	public function new_password($rnd_string){
		$user_id = $password_model->get_user_id($rnd_string);
		if(isset($user_id)){
			$data['random_string'] = $rnd_string;

			$this->form_validation->set_rules('new_pass', 'New Password', 'trim|xss_clean|required');
			$this->form_validation->set_rules('new_pass_again', 'New Password(Again)', 'trim|xss_clean|required');

			if ($this->form_validation->run() !== FALSE){
				if($this->password_check() == true){
					$new_pass = $this->input->post('new_pass');
					$control = array(
						'psswrd' => md5($new_pass)
					);
					$password_model->change_pass($user_id,$control);

					$message = 'Your password has been changed. Your new password is: '.$new_pass;
					$email = $password_model->get_email($user_id);

					$send_email = array(
						'message' => $message,
						'email' => $email
					);
					$mailCheck = $this->sendMAil($send_email);

					$rnd_str = array(
						'random_string' => null,
						'click_control' => 0
					);
											
											if($mailCheck) {
													$message = 'Your mail has been sent.';
											} else {
													$message = 'Your mail has not been sent.You could not change password';
											}
											$password_model->set_random_string_zero($rnd_string,$rnd_str);
											$data['success'] = $message;
					//redirect('login','refresh');
				}
			}

			echo view('template/header');
			echo view('password/new_pass',$data);
			echo view('template/footer');
		}else{
			echo "Wrong pass number.";
		}
	}

	// sends mail to user. We need to change this settings.
	public function sendMail($data)
	{
		$config = Array(
		  'protocol' => 'smtp',
		  'smtp_host' => 'ssl://smtp.googlemail.com',
		  'smtp_port' => 465,
		  'smtp_user' => 'celero.info@gmail.com', // change it to yours
		  'smtp_pass' => '8dwa9z&*', // change it to yours
		  'mailtype' => 'html',
		  'charset' => 'iso-8859-1',
		  'wordwrap' => TRUE
		);

		//config should be set.
		$email = service('email');
		$email->setFrom('celero.info@gmail.com', 'Celero Project');
		$email->setTo($data['email']);
		$email->setSubject('About your ecoman account');
		$email->setMessage($data['message']);
		if($email->send())
		{
            return true;
		}
		else
		{
			echo 'error sending email. please report to celero.info@gmail.com';
			//exit();
            return false;
		}
	}

	// checks password matches
	public function password_check(){
		if($this->input->post('new_pass') == $this->input->post('new_pass_again')){
			return true;
		}
		else{
			$this->form_validation->set_message('password_check','Passwords aren\'t same.');
			return false;
		}
	}

	// generates 20 char random string for every user.
	public function generateRandomString() {
	    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
	    $randomString = '';
	    for ($i = 0; $i < 20; $i++) {
	        $randomString .= $characters[rand(0, strlen($characters) - 1)];
	    }
	    return $randomString;
	}

	// come on.
	public function user_logout(){
		$this->session->sess_destroy();
		redirect('', 'refresh');
	}
}
?>
