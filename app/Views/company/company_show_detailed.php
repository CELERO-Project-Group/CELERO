<div class="container">
	<div class="row">
		<div class="col-md-4">


			<?php if (session()->id): ?>
				<?php if ($canEdit == '1'): ?>
					<a class="btn btn-inverse btn-block" style="margin-bottom: 10px;"
						href="<?= base_url("new_flow/" . $companies['id']) ?>"><i class="fa fa-database"></i>
						<?= lang("Validation.editcompanydata") ?>
					</a>
					<a class="btn btn-inverse btn-block" style="margin-bottom: 10px;"
						href="<?= base_url("update_company/" . $companies['id']) ?>"><i class="fa fa-pencil-square-o"></i>
						<?= lang("Validation.editcompanyinfo") ?>
					</a>
					<button class="btn btn-block btn-inverse" style="width:100%; margin-bottom: 10px;"
						onclick="$('#target').toggle();">Add New User</button>

					<div id="target" class="well" style="display: none">
						<p>
							Here you can give other Users access to your Company. Select users to add. Added users will have
							full access to this company.
						</p>
						<div class="content">
							<p>
								<?= form_open(site_url('addUsertoCompany/' . $companies['id'])) ?>
								<?= csrf_field() ?>
								<select id="users" class="info select-block" name="users">
									<?php foreach ($users_without_company as $user): ?>
										<option value="<?= $user['id'] ?>">
											<?= $user['name'] . ' ' . $user['surname'] ?>
										</option>
									<?php endforeach ?>
								</select>
								<button type="submit" class="btn btn-primary">Add Users</button>
								</form>

							</p>
						</div>
					</div>
				<?php endif ?>
			<?php endif ?>
			<div class="form-group" style="margin-bottom:20px;">
				<div class="swissheader" style="font-size:15px;">
					<?= lang("Validation.companyprojects") ?>
				</div>
				<ul class="nav nav-list">
					<?php foreach ($prjname as $prj): ?>
						<li><a style="text-transform:capitalize;" href="<?= base_url('project/' . $prj['proje_id']) ?>">
								<?= $prj["name"] ?>
							</a></li>
					<?php endforeach ?>
				</ul>
			</div>

			<div class="form-group">
				<div class="swissheader" style="font-size:15px;">
					<?= lang("Validation.companyusers") ?>
				</div>
				<ul class="nav nav-list">
					<?php foreach ($cmpnyperson as $cmpprsn): ?>
						<li><a style="text-transform:capitalize;" href="<?= base_url('user/' . $cmpprsn["user_name"]); ?>">
								<?= $cmpprsn["name"] . ' ' . $cmpprsn["surname"] ?>
							</a></li>

						<a href="<?= base_url("removeUserfromCompany/" . $companies['id'] . "/" . $cmpprsn['id']) ?>"><i
								class="fa fa-pencil-square-o"></i> remove</a>
					<?php endforeach ?>
				</ul>
			</div>
			<?php if ($canDelete == '1'): ?>
				<a style="margin-top: 10px;" class="btn btn-danger btn-block"
					href="<?= base_url("deletecompany/" . $companies['id']) ?>"
					onclick="return confirm('Are you sure you want to delete the company <?= $companies['name'] ?>? \r\n \r\nWarning: The company will be deleted permanently and cannot be restored!');"><i
						class="fa fa-trash"></i>
					<?= lang("Validation.deletecompany") ?>
				</a>
			<?php endif ?>
		</div>
		<div class="col-md-8">
			<div class="swissheader">
				<?= $companies['name'] ?>
			</div>

			<table class="table table-bordered">
				<tr>
					<td style="width:150px;">
						<?= lang("Validation.description") ?>
					</td>
					<td>
						<?= $companies['description'] ?>
					</td>
				</tr>
				<tr>
					<td>
						<?= lang("Validation.email") ?>
					</td>
					<td>
						<?= $companies['email'] ?>
					</td>
				</tr>
				<tr>
					<td>
						<?= lang("Validation.workphone") ?>
					</td>
					<td>
						<?= $companies['phone_num_2'] ?>
					</td>
				</tr>
				<!-- <tr>
					<td>
						<?= lang("Validation.faxnumber") ?>
					</td>
					<td>
						<?= $companies['fax_num'] ?>
					</td>
				</tr> -->
				<tr>
					<td>
						Nace Code
					</td>
					<td>
						<?php
						echo $nacecode['code'] . " - " . $nacecode['name']
							?>
					</td>
				</tr>
				<tr>
					<td>
						<?= lang("Validation.address") ?>
					</td>
					<td>
						<?= $companies['address'] ?>
					</td>
				</tr>
				<tr>
					<td></td>
					<td>
					
						<div id="map"></div>
						<script type="text/javascript">
							var latitude = <?=  $companies['latitude'] ?>;
							var longitude = <?= $companies['longitude'] ?>

							var map = L.map('map', {
								center: [48.505, 11.59],
								zoom: 3
							});
							map.fitWorld().zoomIn();

							map.on('resize', function (e) {
								map.fitWorld({ reset: true }).zoomIn();
							});
							mapLink =
								'<a href="http://openstreetmap.org">OpenStreetMap</a>';
							L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
								attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
							}).addTo(map);


							L.marker = new L.marker([latitude, longitude])
								.addTo(map);

						</script>

					</td>


				</tr>
			</table>
			<?php if ($have_permission): ?>
				<?php if ($valid != 0): ?>

					<table class="table table-bordered">
						<tr class="success">
							<th colspan="7">
								<?= lang("Validation.companyflows") ?>
							</th>
						</tr>
						<tr>
							<th>
								<?= lang("Validation.name") ?>
							</th>
							<th>
								<?= lang("Validation.flowtype") ?>
							</th>
							<th colspan="2" style="text-align: center;">
								<?= lang("Validation.quantity") ?>
							</th>
							<th colspan="2" style="text-align: center;">
								<?= lang("Validation.cost") ?>
							</th>
							<th style="text-align: center;">
								<?= lang("Validation.ep") ?>
							</th>
						</tr>
						<?php foreach ($company_flows as $flows): ?>
							<tr>
								<td>
									<?= $flows['flowname']; ?>
								</td>
								<td>
									<?= $flows['flowtype']; ?>
								</td>
								<td class="table-numbers">
									<?= number_format($flows['qntty'], 0, ".", "'") ?>
								</td>
								<td class="table-units">
									<?= $flows['qntty_unit_name'] ?>
								</td>
								<td class="table-numbers">
									<?= number_format($flows['cost'], 0, ".", "'") ?>
								</td>
								<td class="table-units">
									<?= $flows['cost_unit'] ?>
								</td>
								<td style="text-align: right">
									<?= number_format($flows['ep'], 0, ".", "'") ?>
								</td>
							</tr>
						<?php endforeach ?>
					</table>

					<table class="table table-bordered">
						<tr class="success">
							<th colspan="3">
								<?= lang("Validation.companyprocess") ?>
							</th>
						</tr>
						<tr>
							<th>
								<?= lang("Validation.name") ?>
							</th>
							<th>
								<?= lang("Validation.flowname") ?>
							</th>
							<th>
								<?= lang("Validation.flowtype") ?>
							</th>
						</tr>
						<?php foreach ($company_prcss as $prcss): ?>
							<tr>
								<td>
									<?= $prcss['prcessname'] ?>
								</td>
								<td>
									<?= $prcss['flowname'] ?>
								</td>
								<td>
									<?= $prcss['flow_type_name'] ?>
								</td>
							</tr>
						<?php endforeach ?>
					</table>

					<table class="table table-bordered">
						<tr class="success">
							<th colspan="2">
								<?= lang("Validation.companycomponents") ?>
							</th>
						</tr>
						<tr>
							<th>
								<?= lang("Validation.flowname") ?>
							</th>
							<th>
								<?= lang("Validation.name") ?>
							</th>
						</tr>
						<?php foreach ($company_component as $cmpnnt): ?>
							<tr>
								<td>
									<?= $cmpnnt['flow_name'] ?>
								</td>
								<td>
									<?= $cmpnnt['component_name'] ?>
								</td>
							</tr>
						<?php endforeach ?>
					</table>

					<table class="table table-bordered">
						<tr class="success">
							<th>
								<?= lang("Validation.companyproducts") ?>
							</th>
						</tr>
						<tr>
							<th>
								<?= lang("Validation.name") ?>
							</th>
						</tr>
						<?php foreach ($company_product as $prdct): ?>
							<tr>
								<td>
									<?= $prdct['name'] ?>
								</td>
							</tr>
						<?php endforeach ?>
					</table>
				<?php endif ?>
			<?php endif ?>
		</div>
	</div>
</div>