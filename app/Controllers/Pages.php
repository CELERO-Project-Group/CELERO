<?php

namespace App\Controllers;

class Pages extends BaseController {

public function view($page)
{
	if (!file_exists('../app/Views/pages/'.$page.'.php'))
	{
		throw \CodeIgniter\Exceptions\PageNotFoundException::forPageNotFound();
	}

	$data['title'] = ucfirst($page); // Capitalize the first letter

	//header için başkba bir fonksyion yaz buraya
	echo view('pages/'.$page, $data);
}

}