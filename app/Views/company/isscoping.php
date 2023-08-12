<script type="text/javascript" src="<?= base_url('assets/js/json2html.js'); ?>"></script>
<script type="text/javascript" src="<?= base_url('assets/js/jquery.json2html.js'); ?>"></script>
<script type="text/javascript" src="<?= base_url('assets/js/selectize.min.js'); ?>"></script>

<div class="">
    <div style="padding:10px 20px;">
        <div>Select Flows to Filter. You can select multiple flows</div>
        <small>When flows selected, system will only show companies which have selected flows in its dataset.</small>
        <select id="selectize-units" class="info select-block" name="selectedFlows" multiple>
            <option value="" disabled selected><?= lang("Validation.pleaseselect"); ?></option>
            <?php foreach ($flowlist as $flow): ?>
                <option value="<?= $flow['id']; ?>"><?= $flow['name']; ?></option>
            <?php endforeach ?>
        </select>

        <input type="button" onclick="getFilteredFlows()" value="Filter" />
        <input type="button" onclick="clearFilteredFlows()" value="Clear Selected" />
    </div>

  <div class="">
    <div class="col-md-6">
        <div class="">Select a Company</div>
          <div class="heightlimit">
          <table style="clear:both; width: 100%;" class="table-hover">
          <?php //print_r($companies); ?>
            <?php foreach ($companies as $com): ?>
              <tr>
                <td style="padding: 10px 15px;">
                <a class="a" href="javascript:;" id="<?= $com['id']; ?>" style="display: block; cursor:pointer;">
                <div class="row">
                  <div class="col-md-9">
                    <div><b><?= $com['name']; ?></b></div>
                    <div><span style="color:#999999; font-size:12px;"><?= $com['description']; ?></span></div>
                  </div>
                  <div class="col-md-3">

                  </div>
                </div>
                </a>
                </td>
              </tr>
            <?php endforeach ?>
            </table>
      </div>
      <div style="margin-top:15px;">
        <div class="swissheader">Detailed information</div>

        <div class="heightlimit" id="info">
          <div class="alert">Please select a company to see detailed information.</div>
        </div>
        <div class="well">
          Non-exist data will be shown as empty.
        </div>
      </div>
    </div>
    <div class="col-md-6">
        <div class="swissheader"><?= $cluster_name['name'];?></div>
        <!-- harita -->
        <link rel="stylesheet" href="https://unpkg.com/leaflet@0.7.3/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet@0.7.3/dist/leaflet.js"></script>
        <?php
        $company_array = array();
        foreach ($companies as $com => $k) {
          $company_array[$com][0] = $k['latitude'];
          $company_array[$com][1] = $k['longitude'];
          $company_array[$com][2] = $k['name'];
          $company_array[$com][3] = $k['id'];
        }
        //print_r($company_array);
        ?>
        <div id="map" style="height: 450px;"></div>
        <h4>Selected potential flow matches</h4>
        <table id="addedFlowsTableId" class="table w-100 table-striped">
          <thead>
              <tr>
                  <th>Company Id</th>
                  <th>Flow Id</th>
                  <th>Flow Name</th>
                  <th>Flow Type</th>
                  <th>Company Name</th>
                  <th>Actions</th> <!-- Actions column added -->
              </tr>
          </thead>
          <tbody>
              <tr class="no-data">
                  <td colspan="5">No matches added yet</td> <!-- colspan changed to 5 -->
              </tr>
          </tbody>
      </table>



    </div>
    
  </div>
</div>
<script type="text/javascript">
   $(".a").click(function(){
        markerFunction($(this)[0].id);
        //alert("as");
    });
</script>
<script type="text/javascript">
          var planes = <?= json_encode($company_array); ?>;
          var bounds = new L.LatLngBounds(planes);

          var map = L.map('map').setView([41.83683, 19.33594], 4);

          map.fitBounds(bounds,{padding: [50,50]});

          mapLink =
              '<a href="http://openstreetmap.org">OpenStreetMap</a>';
          L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
          }).addTo(map);

          var markers = [];
          for (var i = 0; i < planes.length; i++) {
            marker = new L.marker([planes[i][0],planes[i][1]], {id: planes[i][3]})
              .bindPopup(planes[i][2])
              .addTo(map)
              .on('popupopen', onClick);

              markers.push(marker);

          }
          //console.log(markers);
          //console.log(markers['0'].options.id);


          function markerFunction(id){
              for (var i in planes){
                  var markerID = markers[i].options.id;
                  if (markerID == id){
                      markers[i].openPopup();
                      //alert("asd");
                  };
              }
          }

          function onClick(e) {
              //console.log(e.target);

              var company_id = e.target.options.id;
              $.ajax({
                  url: '<?= base_url('tuna_json'); ?>/'+company_id,
                  data: {
                    format: 'json'
                  },
                  error: function() {
                    $('#info').html('<p>An error has occurred</p>');
                  },
                  dataType: 'json',
                  success: function(data) {
                    //alert("ds");
                    console.log(data);
                    //var $title = $('<h1>').text(data.name);
                    //var $description = $('<p>').text(data.description);
                    //$('#info').html('<table class="table table-bordered"><tr><td style="width:150px;">Company Info</td><td>'+data.name+'</td></tr><tr><td>E-mail</td><td>'+data.email+'</td></tr><tr><td>Phone</td><td>'+data.phone_num_1+'</td></tr><tr><td>Work Phone</td><td>'+data.phone_num_2+'</td></tr><tr><td>Fax Phone</td><td>'+data.fax_num+'</td></tr><tr><td>Address</td><td>'+data.address+'</td></tr></table>');
                    //$('#info').html(JSON.stringify(data, undefined, 2));
                    $('#info').html("");
                    var transform =
  {"tag":"table","class":"table table-bordered","children":[
    {"tag":"tbody","children":[
        {"tag":"tr","children":[
            {"tag":"td","html":"Company ID"},
            {"tag":"td","colspan":"4","html":"${company_info.id}"}
          ]},
        {"tag":"tr","children":[
            {"tag":"td","html":"Company Info"},
            {"tag":"td","colspan":"4","html":"<h4>${company_info.name}</h4>"}
          ]},
        {"tag":"tr","children":[
            {"tag":"td","html":"E-mail"},
            {"tag":"td","colspan":"4","html":"${company_info.email}"}
          ]},
        {"tag":"tr","children":[
            {"tag":"td","html":"Phone"},
            {"tag":"td","colspan":"4","html":"${company_info.phone_num_1}"}
          ]},
        {"tag":"tr","children":[
            {"tag":"td","html":"Work Phone"},
            {"tag":"td","colspan":"4","html":"${company_info.phone_num_2}"}
          ]},
        {"tag":"tr","children":[
            {"tag":"td","html":"Fax Phone"},
            {"tag":"td","colspan":"4","html":"${company_info.fax_num}"}
          ]},
        {"tag":"tr","children":[
            {"tag":"td","html":"Address"},
            {"tag":"td","colspan":"4","html":"${company_info.address}"}
          ]}
      ]},
    {"tag":"tbody","children":[
        {"tag":"tr","class":"success","children":[
            {"tag":"th","colspan":"5","html":"Company Flows"}
          ]},
        {"tag":"tr","children":[
            {"tag":"th","html":"Flow Name"},
            {"tag":"th","html":"Flow Type"},
            {"tag":"th","html":"Quantity"},
            {"tag":"th","html":"Cost"},
            {"tag":"th","html":"EP"}
          ]},

        {"tag":"tbody","children":function() {
            return(json2html.transform(this.company_flows,company_flows_transform,{'events':true}));
          }}
      ]},
      {"tag":"tbody","children":[
        {"tag":"tr","class":"success","children":[
            {"tag":"th","colspan":"5","html":"Company Processes"}
          ]},
        {"tag":"tr","children":[
            {"tag":"th","colspan":"3","html":"Process Name"},
            {"tag":"th","html":"Flow Name"},
            {"tag":"th","html":"Flow Type"},
        ]},

        {"tag":"tbody","children":function() {
            return(json2html.transform(this.company_prcss,company_process_transform,{'events':true}));
          }}
      ]},
      {"tag":"tbody","children":[
        {"tag":"tr","class":"success","children":[
          {"tag":"th","colspan":"5","html":"Company Equipment"}
        ]},
        {"tag":"tr","children":[
            {"tag":"th","colspan":"3","html":"Equipment Name"},
            {"tag":"th","html":"Equipment Type Name"},
            {"tag":"th","html":"Used Process"},
        ]},

        {"tag":"tbody","children":function() {
            return(json2html.transform(this.company_equipment,company_eq_transform,{'events':true}));
          }}
      ]},
      {"tag":"tbody","children":[
        {"tag":"tr","class":"success","children":[
          {"tag":"th","colspan":"5","html":"Company Products"}
        ]},
        {"tag":"tr","children":[
            {"tag":"th","colspan":"3","html":"Product Name"},
            {"tag":"th","html":"Period"},
            {"tag":"th","html":"Cost"},
        ]},

        {"tag":"tbody","children":function() {
            return(json2html.transform(this.company_product,company_prd_transform,{'events':true}));
          }}
      ]}
  ]};

  $(document).off('click', '.add-flow-btn').on('click', '.add-flow-btn', function() {
    var companyInfo = {
      companyId: $("td:contains('Company ID')").next().text(),
      companyName: $("td:contains('Company Info')").next().text(),

  };
    var flowId = $(this).data('flow-id');
    var flowName = $(this).data('flow-name');
    var flowType = $(this).data('flow-type');  // Capture flow type

    // Here we use the companyName from companyInfo object
    var companyName = companyInfo.companyName;
    var companyId = companyInfo.companyId;

    // Create a new row in "Added Flows" table
    var newRow = '<tr><td>' + companyId + '</td><td>' + flowId + '</td><td>' + flowName + '</td><td>' + flowType + '</td><td>' + companyName + '</td><td><button class="btn btn-danger remove-row-btn">Remove</button></td></tr></tr>';

    // Add the new row to "Added Flows" table
    $('#addedFlowsTableId').append(newRow);

    if ($('#addedFlowsTableId tbody tr').length > 1) {
        $('.no-data').hide();
        $('.send-row').show();
    } else {
        $('.no-data').show();
        $('.send-row').hide();
    }
  });

  $(document).on('click', '.remove-row-btn', function() {
      $(this).closest('tr').remove();

      // Update visibility of "No matches added yet" row and "Send to CP Scoping" row
      if ($('#addedFlowsTableId tbody tr').length > 1) {
          $('.no-data').hide();
          $('.send-row').show();
      } else {
          $('.no-data').show();
          $('.send-row').hide();
      }
  });

  var company_flows_transform =
  {
    "tag":"tr","children":[
      {
        "tag":"td",
        "children":[
          {
            "tag":"div",
            "children": [
              {
                "tag":"a",
                "style":"display:block;margin-bottom: 10px;color: #00098b;background-color: #f0f0f0;border-radius: 4px;padding: 6px;",
                "href":"<?= base_url('nis'); ?>/${flow_id}",
                "html":"${flowname}"
              },
              {
                "tag": "button",
                "class": "btn btn-primary add-flow-btn btn-sm",
                "data-flow-id": "${flow_id}",
                "data-company-id": "${company_info.id}",
                "data-company-name": "${company_info.name}",
                "data-flow-name": "${flowname}",
                "data-flow-type": "${flowtype}",  // Store flow type as a data attribute
                "html": "Add to Matches"
              }
            ]
          }
        ]
      },
      {"tag":"td","html":"${flowtype}"},
      {"tag":"td","html":"${qntty} ${cost_unit}"},
      {"tag":"td","html":"${cost} ${qntty_unit_name}"},
      {"tag":"td","html":"${ep} EP"}
    ]
  };

  var company_process_transform =
    {"tag":"tr","children":[
      {"tag":"td","colspan":"3","html":"${prcessname}"},
      {"tag":"td","html":"${flowname}"},
      {"tag":"td","html":"${flow_type_name}"},
    ]};

  var company_eq_transform =
    {"tag":"tr","children":[
      {"tag":"td","colspan":"3","html":"${eqpmnt_name}"},
      {"tag":"td","html":"${eqpmnt_type_name}"},
      {"tag":"td","html":"${prcss_name}"},
    ]};

  var company_prd_transform =
    {"tag":"tr","children":[
      {"tag":"td","colspan":"3","html":"${name}"},
      {"tag":"td","html":"${tper}"},
      {"tag":"td","html":"${ucost} ${ucostu}"},
    ]};
            $('#info').json2html(data, transform, {replace:false});
          },
          type: 'GET'
      });

        //harita oynatma
        var cM = map.project(e.popup._latlng);
        map.setView(map.unproject(cM),16, {animate: true});
  }
</script>
<script>
    // used for flow filtering on new IS page.
    var $select = $('#selectize-units').selectize({
        create: false,
        closeAfterSelect: true
    });
    // this is the select element.
    var selectize = $select[0].selectize;
    function getFilteredFlows(){
        console.log("selected flow ids: " + selectize.items);
        var link = '<?= base_url('/isscoping/')."/'+selectize.items.toString().replace(/,/g, '-')"; ?>;
        //TODO: it is working right now but I need to modify controllers as well. Until its done, i will comment next line.
        window.location.replace(link);
    }
    function clearFilteredFlows(){
        selectize.clear();
    }
</script>