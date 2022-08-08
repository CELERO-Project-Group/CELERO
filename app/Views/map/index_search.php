
<link rel="stylesheet" type="text/css" href="<?= base_url('assets/map/thirdPartyResources/ext-js/3.4.1.1/resources/css/ext-all-theme-easyui.css'); ?>"/>
<!--<link rel="stylesheet" type="text/css" href="../../resources/themes/greenery/css/xtheme-greenery.css"/>-->

<script type="text/javascript" src="<?= base_url('assets/map/thirdPartyResources/ext-js/3.4.1.1/adapter/ext/ext-base.js'); ?>"></script>
<script type="text/javascript" src="<?= base_url('assets/map/thirdPartyResources/ext-js/3.4.1.1/ext-all.js'); ?>"></script>

<!-- External lib: Google Maps -->
<link rel="stylesheet" type="text/css" href="<?= base_url('assets/map/thirdPartyResources/openlayers/2.12/theme/default/style.css'); ?>"/>
<script type="text/javascript" src="http://maps.googleapis.com/maps/api/js?sensor=false"></script>

<!-- External lib: OpenLayers -->
<script type="text/javascript" src="<?= base_url('assets/map/thirdPartyResources/openlayers/2.12/OpenLayers.js'); ?>"></script>

<!-- External lib: GeoExt 1.0 -->
<script type="text/javascript" src="<?= base_url('assets/map/thirdPartyResources/geoext/1.1/script/GeoExt.js'); ?>"></script>

<?php   if($site_lang==null || $site_lang=='') { ?>
    <script type="text/javascript" src="<?= base_url('assets/map/lib/i18n/en_US.js'); ?>"></script>
<?php  }else if($site_lang=='turkish'){ ?>
    <script type="text/javascript" src="<?= base_url('assets/map/lib/i18n/tr_TR.js'); ?>"></script>
<?php  }else { ?>
    <script type="text/javascript" src="<?= base_url('assets/map/lib/i18n/en_US.js'); ?>"></script>
<?php  } ?>
    

<!-- External lib: geoext-viewer -->


<script type="text/javascript" src="<?= base_url('assets/map/ux/oleditor/ole/client/lib/Editor/Lang/en.js'); ?>"></script>
<!--<script type="text/javascript" src="/openlayers-editor/justs.ole.git/client/lib/Editor/Lang/en.js"></script>-->
<!--<script type="text/javascript" src="/openlayers-editor/justs.ole.git/client/lib/loader.js"></script>-->
<!--<script type="text/javascript" src="../../ux/oleditor/ole/client/lib/loader.js"></script>-->
<script type="text/javascript" src="<?= base_url('assets/map/ux/oleditor/ole/ole.min.js'); ?>"></script>



<script src="<?= base_url('assets/map/lib/DynLoader.js'); ?>" type="text/javascript"></script>
<!--<link rel="stylesheet" type="text/css" href="<?= base_url('assets/map/resources/css/default.css'); ?>"/>-->
<link rel="stylesheet" type="text/css" href="<?= base_url('assets/map/resources/css/default-theme-easyui.css'); ?>"/>
<link rel="stylesheet" href="<?= base_url('assets/map/ux/oleditor/ole/client/theme/geosilk/geosilk.css'); ?>" type="text/css" />
<!--<script type="text/javascript" src="../../script/Ostim.js"></script>-->
<!--<script type="text/javascript" src="<?= base_url('assets/map/DefaultOptionsWorld.js'); ?>"></script>
<!--<script type="text/javascript" src="../featureinfopanel/Config.js"></script>-->
<!--<script type="text/javascript" src="Config.js"></script>-->

<!--<script type="text/javascript" src="../../lib/i18n/nl_NL.js"></script>-->
</head>
<body>

    <input id='latitude' type="hidden" value=<?= $projects['latitude'] ?>>
    <input id='longitude' type="hidden" value=<?= $projects['longitude'] ?>>
    <input type ="hidden" value='<?= $project_id; ?>' id ='prj_id' name='prj_id'></input>

<script>
    
    /*var lonLat= new OpenLayers.LonLat(parseFloat('6.1468505859375'), 
                                  parseFloat('46.195517406488484 ')).transform(new  OpenLayers.Projection("EPSG:4326"), 
                                  new OpenLayers.Projection("EPSG:900913"))*/
    
    /*var lonLat= new OpenLayers.LonLat(parseFloat('6.1468505859375'), 
                                  parseFloat('46.195517406488484 ')).transform(new  OpenLayers.Projection("EPSG:4326"), 
                                  new OpenLayers.Projection("EPSG:900913"))*/
    var lonLat = new OpenLayers.LonLat(parseFloat(document.getElementById('longitude').value), 
                                  parseFloat(document.getElementById('latitude').value)).
                                          transform(new  OpenLayers.Projection("EPSG:4326"), 
                                  new OpenLayers.Projection("EPSG:900913"));
    
    
Ext.namespace("Ostim");
Ext.namespace("Ostim.options");
Ext.namespace("Ostim.options.wfs");


Ostim.searchPanelConfig = {
    xtype: 'hr_searchcenterpanel',
    id: 'hr-searchcenterpanel',
    height: 600,
    border: true,
    hropts: {
        searchPanel: {
            xtype: 'hr_formsearchpanel',
            header: false,
            border: false,
            protocol: new OpenLayers.Protocol.WFS({
                /*version: "1.1.0",
                url: ['http://kademo.nl/gs2/wfs?', 'http://kademo.nl/gs2/wfs?'],
                srsName: "EPSG:28992",
                featureType: "hockeyclubs",
                featureNS: "http://innovatie.kadaster.nl"*/
                version: "1.1.0",
                url: ['http://88.249.18.205:8445/geoserver/wfs?', 'http://88.249.18.205:8445/geoserver/wfs?'],
                //srsName: "EPSG:4326",
                srsName: "EPSG:900913",
                featureType: "view_gis_project_firms",
                geometryName : "geom"
                //featureNS: "ecoman"
            }),
            downloadFormats: [],
            items: [
                {
                    /*xtype: "textfield",
                    name: "name__like",
                    value: 'hu',
                    fieldLabel: "  Name"*/
                    xtype: "textfield",
                    name: "cmpny_name__like",
                    value: 'company name',
                    fieldLabel: "  ad"
                },
//                {
//                     xtype: "textfield",
//                     name: "cmt__like",
//                     fieldLabel: "  Desc"
//                 },
                {
                    xtype: "label",
                    id: "helplabel",
                    html: 'TEst search panel 1<br/>Any single letter will also yield results. <br/>See also the <a href="Config.js">Config.js here</a>',
                    style: {
                        fontSize: '10px',
                        color: '#AAAAAA'
                    }
                }
            ],
            hropts: {
                onSearchCompleteZoom: 10,
                autoWildCardAttach: true,
                caseInsensitiveMatch: true,
                logicalOperator: OpenLayers.Filter.Logical.AND,
                statusPanelOpts: {
                    html: '&nbsp;',
                    height: 'auto',
                    preventBodyReset: true,
                    bodyCfg: {
                        style: {
                            padding: '6px',
                            border: '0px'
                        }
                    },
                    style: {
                        marginTop: '2px',
                        paddingTop: '2px',
                        fontFamily: 'Verdana, Arial, Helvetica, sans-serif',
                        fontSize: '11px',
                        color: '#0000C0'
                    }
                }
            }
        },
        resultPanel: {
            xtype: 'hr_featuregridpanel',
            id: 'hr-featuregridpanel',
            header: false,
            border: false,
            columns: [
                {
                    header: "Name",
                    width: 100,
                    dataIndex: "cmpny_name"
                    //dataIndex: "name"
                },
                {
                    header: "Desc",
                    width: 200,
                    dataIndex: "prj_name"
                }
            ],
            exportFormats: ['CSV', 'XLS', 'GMLv2',
                {
                    name: 'Esri Shapefile (Dutch RD EPSG:28992)',
                    formatter: 'OpenLayersFormatter',
                    format: 'OpenLayers.Format.GeoJSON',
                    targetFormat: 'ESRI Shapefile',
                    targetSrs: 'EPSG:28992',
                    fileExt: '.zip',
                    mimeType: 'application/zip'
                },
                {
                    name: 'Esri Shapefile (WGS84 EPSG:4326)',
                    formatter: 'OpenLayersFormatter',
                    format: 'OpenLayers.Format.GeoJSON',
                    targetFormat: 'ESRI Shapefile',
                    targetSrs: 'EPSG:4326',
                    fileExt: '.zip',
                    mimeType: 'application/zip'
                },
                'GeoJSON', 'WellKnownText'],
            hropts: {
                zoomOnRowDoubleClick: true,
                zoomOnFeatureSelect: false,
                zoomLevelPointSelect: 8
            }
        }
    }
};

Ostim.searchPanelConfigFlow = {
    xtype: 'hr_searchcenterpanelflow',
    id: 'hr-searchcenterpanelflow',
    height: 600,
    border: true,
    hropts: {
        searchPanel: {
            xtype: 'hr_formsearchpanelflow',
            header: false,
            border: false,
            protocol: new OpenLayers.Protocol.WFS({
                /*version: "1.1.0",
                url: ['http://kademo.nl/gs2/wfs?', 'http://kademo.nl/gs2/wfs?'],
                srsName: "EPSG:28992",
                featureType: "hockeyclubs",
                featureNS: "http://innovatie.kadaster.nl"*/
                version: "1.1.0",
                url: ['http://88.249.18.205:8445/geoserver/wfs?', 'http://88.249.18.205:8445/geoserver/wfs?'],
                //srsName: "EPSG:4326",
                srsName: "EPSG:900913",
                featureType: "view_gis_project_firms",
                geometryName : "geom"
                //featureNS: "ecoman"
            }),
            downloadFormats: [],
            items: [
                {
                    /*xtype: "textfield",
                    name: "name__like",
                    value: 'hu',
                    fieldLabel: "  Name"*/
                    xtype: "textfield",
                    name: "prj_name__like",
                    value: 'project name..',
                    fieldLabel: "  ad"
                },
                
                {
                    /*xtype: "textfield",
                    name: "name__like",
                    value: 'hu',
                    fieldLabel: "  Name"*/
                    xtype: "textfield",
                    name: "cmpny_name__like",
                    value: 'company name..',
                    fieldLabel: "  company Name"
                },
//                {
//                     xtype: "textfield",
//                     name: "cmt__like",
//                     fieldLabel: "  Desc"
//                 },
                {
                    xtype: "label",
                    id: "helplabelflow",
                    html: 'TEst search panel 2<br/>Any single letter will also yield results. <br/>See also the <a href="Config.js">Config.js here</a>',
                    style: {
                        fontSize: '10px',
                        color: '#AAAAAA'
                    }
                }
            ],
            hropts: {
                onSearchCompleteZoom: 10,
                autoWildCardAttach: true,
                caseInsensitiveMatch: true,
                //logicalOperator: OpenLayers.Filter.Logical.AND,
                logicalOperator: OpenLayers.Filter.Logical.OR,
                statusPanelOpts: {
                    html: '&nbsp;',
                    height: 'auto',
                    preventBodyReset: true,
                    bodyCfg: {
                        style: {
                            padding: '6px',
                            border: '0px'
                        }
                    },
                    style: {
                        marginTop: '2px',
                        paddingTop: '2px',
                        fontFamily: 'Verdana, Arial, Helvetica, sans-serif',
                        fontSize: '11px',
                        color: '#0000C0'
                    }
                }
            }
        },
        resultPanel: {
            xtype: 'hr_featuregridpanelflow',
            id: 'hr-featuregridpanelflow',
            /*xtype: 'hr_featurepanelflow',
            id: 'hr-featurepanelflow',*/
            header: false,
            border: false,
            columns: [
                {
                    header: "Name",
                    width: 100,
                    dataIndex: "cmpny_name"
                    //dataIndex: "name"
                },
                {
                    header: "Desc",
                    width: 200,
                    dataIndex: "prj_name"
                }
            ],
            exportFormats: ['CSV', 'XLS', 'GMLv2',
                {
                    name: 'Esri Shapefile (Dutch RD EPSG:28992)',
                    formatter: 'OpenLayersFormatter',
                    format: 'OpenLayers.Format.GeoJSON',
                    targetFormat: 'ESRI Shapefile',
                    targetSrs: 'EPSG:28992',
                    fileExt: '.zip',
                    mimeType: 'application/zip'
                },
                {
                    name: 'Esri Shapefile (WGS84 EPSG:4326)',
                    formatter: 'OpenLayersFormatter',
                    format: 'OpenLayers.Format.GeoJSON',
                    targetFormat: 'ESRI Shapefile',
                    targetSrs: 'EPSG:4326',
                    fileExt: '.zip',
                    mimeType: 'application/zip'
                },
                'GeoJSON', 'WellKnownText'],
            hropts: {
                zoomOnRowDoubleClick: true,
                zoomOnFeatureSelect: false,
                zoomLevelPointSelect: 8
            }
        }
    }
};





Ostim.options.bookmarks =
		[
			{
				id: 'ostim',
				name: 'Ostim Teknoloji',
				desc: 'Ostim Teknoloji Yerleşkesi',
				layers: ['OpenStreetMap', 'Ostim Enerji ve Çevre Kümelenmesi', 'Ostim Savunma Kümelenmesi', 'Ostim Medikal Kümelenmesi', 'Ostim Kauçuk Kümelenmesi', 'Ostim İş ve İş Makinaları Kümelenmesi', 'Anadolu Raylı Sistemler Kümelenmesi'],
				/*x: 3645188.674212186,
				y: 4862142.814161345,*/
                                  /*x: 46.195517406488484,
                                  y: 6.1468505859375,*/
				zoom: 17
			}
		];




//Ext.namespace("Ostim");
OpenLayers.ProxyHost = "/cgi-bin/proxy.cgi?url=";

//Ext.namespace("Ostim.options.wfs");
Ostim.options.wfs.downloadFormats = [
    {
        name: 'CSV',
        outputFormat: 'csv',
        fileExt: '.csv'
    }
//    {
//        name: 'GML (version 2.1.2)',
//        outputFormat: 'text/xml; subtype=gml/2.1.2',
//        fileExt: '.gml'
//    },
//    {
//        name: 'ESRI Shapefile (zipped)',
//        outputFormat: 'SHAPE-ZIP',
//        fileExt: '.zip'
//    },
//    {
//        name: 'GeoJSON',
//        outputFormat: 'json',
//        fileExt: '.json'
//    }
];


/**
 * Defines the entire layout of a Ostim webapp using ExtJS-style.
 **/
Ostim.layout = {
	xtype: 'panel',
        /*xtype: 'hr_mappanel',
        height: 1000,
	width: 1000,
        renderTo: 'mapdiv',*/
	id: 'hr-container-main',
        
	layout: 'border',
        
	items: [
                {
			/** North container: fixed banner plus Menu. */
			xtype: 'panel',
			id: 'hr-container-north',
			region: 'north',
			layout: 'border',
			width: '100%',
			height: 50,
			bodyBorder: false,
			border: false,
			items :  [
				{
					xtype: 'hr_htmlpanel',
					id: 'hr-logo-panel',
					region: 'center',
					bodyBorder: false,
					border: false,
					autoLoad: {
						//url: 'http://88.249.18.205:8090/ecoman_zeynel/mapHeader'
                                                url: 'mapHeader'
					},
					height: 55

				},
				/*{
					xtype: 'hr_menupanel',
					id: 'hr-menu-panel',
					region: 'south',
					bodyBorder: false,
					border: false,
					height: 28,
					/** Menu options, see widgets/MenuPanel */
					/*hropts: {
						pageRoot: 'content/',
						cardContainer: 'hr-container-center',
						pageContainer: 'hr-content-main',
						defaultCard: 'hr-content-main',
						defaultPage: 'inspire'
					},
					/** See above for the items. */
					/*items: Heron.geoportal.menuItems
				}*/
			]
		},
		{
			xtype: 'panel',

			id: 'hr-menu-left-container',
			layout: 'accordion',
			region : "west",
			width: 240,
			collapsible: true,
			split	: true,
			border: false,
			items: [
                            /*
                                {
                                    // ptype: "gxp_layertree",
                                    ptype: "gxp_layermanager",

                                    outputConfig: {
                                        id: "layertree",
                                        title: __('Layers'),
                                        border: false,
                                        tbar: [] // we will add buttons to "tree.bbar" later
                                    },
                                    outputTarget: "hr-menu-left-container"
                                },
                            */
                            // search panel test
                            // zeynel dağlı
                            /*{
                                    xtype: 'hr_formsearchpanel',
                                    title: __('Search'),
                                    bodyStyle: 'padding: 6px',
                                    style: {
                                        fontFamily: 'Verdana, Arial, Helvetica, sans-serif',
                                        fontSize: '12px'
                                    },
                                    border: true,

                                    protocol: new OpenLayers.Protocol.WFS({
                                       
                                        version: "1.1.0",
                                        url: ['http://88.249.18.205:8445/geoserver/wfs?', 'http://88.249.18.205:8445/geoserver/wfs?'],
                                        srsName: "EPSG:4326",
                                        featureType: "view_gis_project_firms",
                                        
                                    }),
                                    items: [
                                        {
                                            xtype: "textfield",
                                            //name: "name__like",
                                            name: "prj_name__like",
                                            value: 'hu',
                                            //fieldLabel: "  name"
                                            fieldLabel: "  ad"
                                        },
                                        {
                                            xtype: "label",
                                            html: 'Type name of an NL hockeyclub. Wildcard autoattached and case insenitive match.<br/>',
                                            style: {
                                                fontSize: '10px',
                                                color: '#CCCCCC'
                                            }
                                        }
                                    ],

                                    hropts: {
                                        onSearchCompleteZoom: 11,
                                        autoWildCardAttach: true,
                                        caseInsensitiveMatch: true,
                                        logicalOperator: OpenLayers.Filter.Logical.AND,
                                        // Optional: make these layers visible when search completes
                                        layerOpts: [
                                            //{ layerOn: 'Hockeyclubs', layerOpacity: 0.9 },
                                            { layerOn: 'Project Companies', layerOpacity: 0.9 },
                                            { layerOn: 'OpenStreetMap', layerOpacity: 1.0 }
                                        ]
                                    }
                                },*/
				{
					xtype: 'hr_layertreepanel',
                                        border: true,

                                        // The LayerTree tree nodes appearance: default is ugly ExtJS document icons
                                        // Other values are 'none' (no icons). May be overridden in specific 'gx_layer' type config.
                                        //layerIcons: 'bylayertype',

                                        // LayerTree is taken from global Ostim context
                                        //useMapContext: true,
                    contextMenu: [
                        {
                            xtype: 'hr_layernodemenulayerinfo'
                        },
                        {
                            xtype: 'hr_layernodemenuzoomextent'
                        },
                        {
                            xtype: 'hr_layernodemenuopacityslider'
                        }
                    ]
				},
                                
                                /*{
                                    title:'GeoServer Servisler',
                                    xtype:'hr_capabilitiesviewpanel',
                                    useArrows:true,
                                    animate:true,
                                    flex: 3,
                                    hropts:{
                                        preload: false
                                    }
                                },*/
                                
                                /*{
                                    xtype: 'hr_bookmarkspanel',
                                    id: 'hr-bookmarks',
                                    border: true,
                                    /** The map contexts to show links for in the BookmarksPanel. */
                                    /*hropts: Ostim.options.bookmarks
                                }*/
			]
		},
                
                
                
                /*{
                    xtype: 'hr_htmlpanel',
                    region: "east",
                    border: true,
                    html: '<div class="hr-html-panel-body"><p>Ostim Teknoloji Mühendislik ve imalât alanlarında karşılaşılan teknik gereksinimlere cevap vermek için kurulmuş bir Ar-Ge şirketidir. Sağladığı mühendislik, danışmanlık ve eğitim hizmetlerinin yanı sıra bölge ve sektöre bağlı olmaksızın yeni teknolojilerin kullanımı, uyarlanması ve geliştirilmesi yönünde araştırma ve geliştirme faaliyetlerinde bulunmaktadır</p>\n\
                         <p>Çeşitli Ar-Ge Projeleri yürütmekte olan OSTİM Teknoloji, "Sanal Fabrika" prototipinin Ostim\'de geliştirilmesine yönelik bir San-tez projesi yürütmektedir. Proje ile Ostim\'li KOBİ\'lerin ortak tasarım, ortak üretim ve ortak pazarlama faaliyetlerini gerçekleştirebilecekleri bir network kurulacaktır.</p>' +
                        '<p>Sanayi projelerinin etkin bir şekilde yürütülmesini sağlamak amacıyla ulusal ve uluslararası işbirlikleri içinde yer alan OSTİM Teknoloji, bilgi ağlarını takip eder, ulusal ve uluslararası Ar-Ge desteklerini projelerine uygular.</p></div>',
                    width: 180,
                    preventBodyReset: true,
                    title: 'Ostim Harita Uygulaması',
                    collapsible: true,
                    split	: true,
                },*/
                
		{
			xtype: 'panel',

			id: 'hr-map-and-info-container',
			layout: 'border',
			region: 'center',
			width: '100%',
			collapsible: true,
			split	: true,
			border: false,
			items: [
                                {
					xtype: 'hr_mappanel',
					id: 'hr-map',
					region: 'center',
					collapsible : false,
					border: false,
					hropts: {
						settings :
						{
							projection: 'EPSG:900913',
							displayProjection: new OpenLayers.Projection("EPSG:4326"),
							units: 'm',
							maxExtent: '-20037508.34, -20037508.34, 20037508.34, 20037508.34',
							//center: '594576, 6831611',
							maxResolution: 'auto',
							xy_precision: 5,
							//zoom: 6,
                                                        center : ''+lonLat.lon+','+ lonLat.lat+'',
                                                        //center: '545465.505, 6854552.133',
                                                        //OSTIM
                                                        //center : '3645188.674212186, 4862142.814161345',
                                                        //center : '6.1468505859375 ,46.195517406488484 ',
                                                        //center : '4449868.515107782, 3861543.6706226687',
                                                        //zoom: 17,
                                                        zoom: 12,
							theme: null,
                                                        //allOverlays: true,
						},

						layers : [
                                                        new OpenLayers.Layer.Google(
									"Google Satellite",
									{type: google.maps.MapTypeId.SATELLITE, visibility: true},
									{singleTile: false, buffer: 0, isBaseLayer: true}

							),

                                                        new OpenLayers.Layer.Google(
                                                                        "Google Streets", // the default
                                                                        {type: google.maps.MapTypeId.ROADMAP, visibility: false},
                                                                        {singleTile: false, buffer: 0, isBaseLayer: true}
                     							),
							new OpenLayers.Layer.Google(
									"Google Terrain",
									{type: google.maps.MapTypeId.TERRAIN, visibility: false},
									{singleTile: false, buffer: 0, isBaseLayer: true}
							),
							new OpenLayers.Layer.OSM(),
                                                        
                                                         /* new OpenLayers.Layer.WMS(
                                                                    "World Cities (FAO)",
                                                                    'http://data.fao.org/geoserver/ows?',
                                                                    {layers: "GEONETWORK:esri_cities_12764", transparent: true, format: 'image/png'},
                                                                    {singleTile: true, opacity: 0.9, isBaseLayer: false, visibility: false, noLegend: false, featureInfoFormat: "application/vnd.ogc.gml"}
                                                            ),*/
                                                        new OpenLayers.Layer.WMS(
                                                                "World Cities (FAO)",
                                                                'http://data.fao.org/geoserver/ows?',
                                                                {layers: "GEONETWORK:esri_cities_12764", transparent: true, format: 'image/png'},
                                                                {singleTile: true, opacity: 0.9, isBaseLayer: false, visibility: true, noLegend: false, featureInfoFormat: 'application/vnd.ogc.gml', transitionEffect: 'resize'}
                                                        ),
                                                        new OpenLayers.Layer.WMS(
                                                            "Ostim Enerji ve Çevre Kümelenmesi",
                                                            'http://88.249.18.205:8445/geoserver/ecoman/wms?',
                                                            {layers: "ecoman:GIS_company", transparent: true, format: 'image/png'},
                                                            {singleTile: false, opacity: 0.9, isBaseLayer: false, visibility: true, noLegend: false, featureInfoFormat: 'application/vnd.ogc.gml', transitionEffect: 'resize'
                                                               ,
                                                           metadata: {
                                                                    wfs: {
                                                                        protocol: 'fromWMSLayer',
                                                                        featurePrefix: 'ecoman:GIS_company',
                                                                        //featureNS: 'http://rdinfo.geonovum.nl',
                                                                       featureNS: 'http://88.249.18.205:8445/geoserver/ecoman',
                                                                        downloadFormats: Ostim.options.wfs.downloadFormats,
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        ),
                                                        /*new OpenLayers.Layer.WMS(
                                                            "Ostim Savunma Kümelenmesi",
                                                            'http://88.249.18.205:8445/geoserver/ecoman/wms?',
                                                            {layers: "ecoman:GIS_Savunma", transparent: true, format: 'image/png'},
                                                            {singleTile: true, opacity: 0.9, isBaseLayer: false, visibility: true, noLegend: false, featureInfoFormat: 'application/vnd.ogc.gml', transitionEffect: 'resize'
                                                               ,
                                                           metadata: {
                                                                    wfs: {
                                                                        protocol: 'fromWMSLayer',
                                                                        featurePrefix: 'ecoman:GIS_Savunma',
                                                                        //featureNS: 'http://rdinfo.geonovum.nl',
                                                                       featureNS: 'http://88.249.18.205:8445/geoserver/ecoman',
                                                                        downloadFormats: Ostim.options.wfs.downloadFormats,
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        ),*/
                                                        /*new OpenLayers.Layer.WMS(
                                                            "Ostim Medikal Kümelenmesi",
                                                            'http://88.249.18.205:8445/geoserver/ecoman/wms?',
                                                            {layers: "ecoman:GIS_Medical", transparent: true, format: 'image/png'},
                                                            {singleTile: true, opacity: 0.9, isBaseLayer: false, visibility: true, noLegend: false, featureInfoFormat: 'application/vnd.ogc.gml', transitionEffect: 'resize'
                                                               ,
                                                           metadata: {
                                                                    wfs: {
                                                                        protocol: 'fromWMSLayer',
                                                                        featurePrefix: 'ecoman:GIS_Medical',
                                                                        //featureNS: 'http://rdinfo.geonovum.nl',
                                                                        featureNS: 'http://88.249.18.205:8445/geoserver/ecoman',
                                                                        downloadFormats: Ostim.options.wfs.downloadFormats,
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        ),*/
                                                        /*new OpenLayers.Layer.WMS(
                                                            "Ostim Kauçuk Kümelenmesi",
                                                            'http://88.249.18.205:8445/geoserver/ecoman/wms?',
                                                            {layers: "ecoman:GIS_Kaucuk", transparent: true, format: 'image/png'},
                                                            {singleTile: true, opacity: 0.9, isBaseLayer: false, visibility: true, noLegend: false, featureInfoFormat: 'application/vnd.ogc.gml', transitionEffect: 'resize'
                                                               ,
                                                           metadata: {
                                                                    wfs: {
                                                                        protocol: 'fromWMSLayer',
                                                                        featurePrefix: 'ecoman:GIS_Kaucuk',
                                                                        //featureNS: 'http://rdinfo.geonovum.nl',
                                                                       featureNS: 'http://88.249.18.205:8445/geoserver/ecoman',
                                                                        downloadFormats: Ostim.options.wfs.downloadFormats,
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        ),*/
                                                        /*new OpenLayers.Layer.WMS(
                                                            "Ostim İş ve İş Makinaları Kümelenmesi",
                                                            'http://88.249.18.205:8445/geoserver/ecoman/wms?',
                                                            {layers: "ecoman:GIS_isim", transparent: true, format: 'image/png'},
                                                            {singleTile: true, opacity: 0.9, isBaseLayer: false, visibility: true, noLegend: false, featureInfoFormat: 'application/vnd.ogc.gml', transitionEffect: 'resize'
                                                               ,
                                                           metadata: {
                                                                    wfs: {
                                                                        protocol: 'fromWMSLayer',
                                                                        featurePrefix: 'ecoman:GIS_isim',
                                                                        //featureNS: 'http://rdinfo.geonovum.nl',
                                                                       featureNS: 'http://88.249.18.205:8445/geoserver/ecoman',
                                                                        downloadFormats: Ostim.options.wfs.downloadFormats,
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        ),*/
                                                        /*new OpenLayers.Layer.WMS(
                                                            "Anadolu Raylı Sistemler Kümelenmesi",
                                                            'http://88.249.18.205:8445/geoserver/ecoman/wms?',
                                                            {layers: "ecoman:GIs_Arus", transparent: true, format: 'image/png'},
                                                            {singleTile: true, 
                                                             opacity: 0.9, 
                                                             isBaseLayer: false, 
                                                             visibility: true, 
                                                             noLegend: false, 
                                                             featureInfoFormat: 'application/vnd.ogc.gml', 
                                                             transitionEffect: 'resize'
                                                               ,
                                                           metadata: {
                                                                    wfs: {
                                                                        protocol: 'fromWMSLayer',
                                                                        featurePrefix: 'ecoman:GIs_Arus',
                                                                        //featureNS: 'http://rdinfo.geonovum.nl',
                                                                        featureNS: 'http://88.249.18.205:8445/geoserver/ecoman',
                                                                        downloadFormats: Ostim.options.wfs.downloadFormats,
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        ),*/
                                                        new OpenLayers.Layer.WMS(
                                                            "Project Companies",
                                                            'http://88.249.18.205:8445/geoserver/ecoman/wms?',
                                                            {layers: "ecoman:view_gis_project_firms", 
                                                                transparent: true, 
                                                                format: 'image/png',
                                                             //cql_filter : "IN('company_id."+from_company+"','company_id."+to_company+"')"
                                                             cql_filter : "id=<?= $project_id; ?>"
                                                            },
                                                            {singleTile: true, 
                                                             opacity: 0.9, 
                                                             isBaseLayer: false, 
                                                             visibility: true, 
                                                             noLegend: false, 
                                                             featureInfoFormat: 'application/vnd.ogc.gml', 
                                                             transitionEffect: 'resize'
                                                               ,
                                                           metadata: {
                                                                    wfs: {
                                                                        protocol: 'fromWMSLayer',
                                                                        featurePrefix: 'ecoman:view_gis_project_firms',
                                                                        //featureNS: 'http://rdinfo.geonovum.nl',
                                                                        featureNS: 'http://88.249.18.205:8445/geoserver/ecoman',
                                                                        downloadFormats: Ostim.options.wfs.downloadFormats,
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        )
                                                           
    
                                                          
                                                            /*
                                                        new OpenLayers.Layer.WMS(
                                                                "World Cities (OpenGeo)",
                                                                'http://suite.opengeo.org/geoserver/ows?',
                                                                {layers: "cities", transparent: true, format: 'image/png'},
                                                                {singleTile: true, opacity: 0.9, isBaseLayer: false, visibility: true,
                                                                    noLegend: false, featureInfoFormat: 'application/vnd.ogc.gml', transitionEffect: 'resize'
                                                                 }
                                                        )*/
						],
						toolbar: [
                                                    {type: "zeynelToolbarItem", options: {
                                                            /* popupWindow: {
                                                                             width: 360,
                                                                             height: 200,
                                                                             featureInfoPanel: {
                                                                                 showTopToolbar: true,
                                                                                 displayPanels: ['Table'],

                                                                                 // Should column-names be capitalized? Default true.
                                                                                 columnCapitalize: true,

                                                                                 // Export to download file. Option values are 'CSV', 'XLS', default is no export (results in no export menu).
                                                                                 exportFormats: ['CSV', 'XLS', 'GMLv2', 'Shapefile', 'GeoJSON', 'WellKnownText'],
                                                                                 // Export to download file. Option values are 'CSV', 'XLS', default is no export (results in no export menu).
                                                                                 // exportFormats: ['CSV', 'XLS'],
                                                                                 maxFeatures: 10
                                                                             }
                                                                         }*/
                                                     }},
                            /**
                             * company info toolbar button
                             * zeynel dağlı
                             */
                            {type: "featureinfo", options: {  
                                popupWindow: {
                                    width: 360,
                                    height: 200,
                                    featureInfoPanel: {
                                        showTopToolbar: true,
                                        displayPanels: ['Table'],

                                        // Should column-names be capitalized? Default true.
                                        columnCapitalize: true,

                                        // Export to download file. Option values are 'CSV', 'XLS', default is no export (results in no export menu).
                                        //exportFormats: ['CSV', 'XLS', 'GMLv2', 'Shapefile', 'GeoJSON', 'WellKnownText'],
                                        // Export to download file. Option values are 'CSV', 'XLS', default is no export (results in no export menu).
                                        // exportFormats: ['CSV', 'XLS'],
                                        maxFeatures: 10
                                    }
                                }
                            }},
							{type: "-"} ,
							{type: "pan"},
							{type: "zoomin"},
							{type: "zoomout"},
							{type: "zoomvisible"},
							{type: "-"} ,
							{type: "zoomprevious"},
							{type: "zoomnext"},
							{type: "-"},
							{type: "measurelength", options: {geodesic: true}},
							{type: "measurearea", options: {geodesic: true}},
                                                        /*{
                                                                // Instead of an internal "type", or using the "any" type
                                                                // provide a create factory function.
                                                                // MapPanel and options (see below) are always passed
                                                                create: function (mapPanel, options) {

                                                                        // A trivial handler
                                                                        options.handler = function () {
                                                                                alert(options.msg);
                                                                        };

                                                                        // Provide an ExtJS Action object
                                                                        // If you use an OpenLayers control, you need to provide a GeoExt Action object.
                                                                        return new Ext.Action(options);
                                                                },

                                                                /* Options to be passed to your create function. */
                                                                /*options: {
                                                                        tooltip: 'My Item',
                                                                        iconCls: "icon-myitem",
                                                                        enableToggle: true,
                                                                        pressed: false,
                                                                        id: "myitem",
                                                                        toggleGroup: "toolGroup",
                                                                        msg: 'Hello from my toolbar item---> TESTTT'
                                                                }
                                                                
                                                        },*/
                            /*
                                                        {type: "printdirect", options: {url: 'http://kademo.nl/print/pdf28992',
                                                            tooltip: __('Print Visible Map Area Directly') + ' JPEG'
                                                                    //, mapTitle: 'My Header - Direct Print'
                                                                    // , mapTitleYAML: "mapTitle"		// MapFish - field name in config.yaml - default is: 'mapTitle'
                                                                    , mapComment: 'My Comment - Direct Print, Output format JPEG'
                                                                    // , mapCommentYAML: "mapComment"	// MapFish - field name in config.yaml - default is: 'mapComment'
                                                                    // , mapFooter: 'My Footer - Direct Print'
                                                                    // , mapFooterYAML: "mapFooter"	    // MapFish - field name in config.yaml - default is: 'mapFooter'
                                                                    // , printAttribution: true         // Flag for printing the attribution
                                                                    // , mapAttribution: null           // Attribution text or null = visible layer attributions
                                                                    // , mapAttributionYAML: "mapAttribution" // MapFish - field name in config.yaml - default is: 'mapAttribution'
                                                                    // , mapPrintLayout: "A4"			// MapFish - 'name' entry of the 'layouts' array or Null (=> MapFish default)
                                                                    // , mapPrintDPI: "75"				// MapFish - 'value' entry of the 'dpis' array or Null (=> MapFish default)
                                                            , mapPrintOutputFormat: 'pdf' // By default uses PDF ('pdf'), but may use e.g. 'jpeg' or 'bmp' see your YAML File
                                                                    // , mapPrintLegend: true
                                                                    // , legendDefaults: {
                                                                    //     useScaleParameter : false,
                                                                    //     baseParams: {FORMAT: "image/png"}
                                                                    //   }
                                                            }},*/
                                                        {type: "help", options: {tooltip: 'Help and info for this example', contentUrl: 'help.html'}},
                                                        {type: "oleditor", options: {
					pressed: true,

					// Options for OLEditor
					olEditorOptions: {
						activeControls: [/*'UploadFeature', 'DownloadFeature',*/ 'Separator', 'Navigation', 'SnappingSettings', 'CADTools', 'Separator',/* 'DeleteAllFeatures', 'DeleteFeature', */'DragFeature',/* 'SelectFeature', 'Separator', 'DrawHole', 'ModifyFeature', 'Separator'*/],
						featureTypes: ['text', 'regular', 'polygon', 'path', 'point'],
						language: 'en',
						DownloadFeature: {
							url: Ostim.globals.serviceUrl,
							formats: [
								{name: 'Well-Known-Text (WKT)', fileExt: '.wkt', mimeType: 'text/plain', formatter: 'OpenLayers.Format.WKT'},
								{name: 'Geographic Markup Language - v2 (GML2)', fileExt: '.gml', mimeType: 'text/xml', formatter: new OpenLayers.Format.GML.v2({featureType: 'oledit', featureNS: 'http://geops.de'})},
								{name: 'GeoJSON', fileExt: '.json', mimeType: 'text/plain', formatter: 'OpenLayers.Format.GeoJSON'},
                                                                {name: 'GPS Exchange Format (GPX)', fileExt: '.gpx', mimeType: 'text/xml', formatter: 'OpenLayers.Format.GPX', fileProjection: new OpenLayers.Projection('EPSG:4326')},
                                                                {name: 'Keyhole Markup Language (KML)', fileExt: '.kml', mimeType: 'text/xml', formatter: 'OpenLayers.Format.KML', fileProjection: new OpenLayers.Projection('EPSG:4326')},
                                                                {name: 'ESRI Shapefile (zipped, Google projection)', fileExt: '.zip', mimeType: 'application/zip', formatter: 'OpenLayers.Format.GeoJSON', targetFormat: 'ESRI Shapefile', fileProjection: new OpenLayers.Projection('EPSG:900913')},
                                                                {name: 'ESRI Shapefile (zipped, WGS84)', fileExt: '.zip', mimeType: 'application/zip', formatter: 'OpenLayers.Format.GeoJSON', targetFormat: 'ESRI Shapefile', fileProjection: new OpenLayers.Projection('EPSG:4326')},
                                                                {name: 'OGC GeoPackage (Google projection)', fileExt: '.gpkg', mimeType: 'application/binary', formatter: 'OpenLayers.Format.GeoJSON', targetFormat: 'GPKG', fileProjection: new OpenLayers.Projection('EPSG:900913')},
                                                                {name: 'OGC GeoPackage (WGS84)', fileExt: '.gpkg', mimeType: 'application/binary', formatter: 'OpenLayers.Format.GeoJSON', targetFormat: 'GPKG', fileProjection: new OpenLayers.Projection('EPSG:4326')}

							],
							// For custom projections use Proj4.js
							fileProjection: new OpenLayers.Projection('EPSG:4326')
						},
						UploadFeature: {
							url: Ostim.globals.serviceUrl,
							formats: [
								{name: 'Well-Known-Text (WKT)', fileExt: '.wkt', mimeType: 'text/plain', formatter: 'OpenLayers.Format.WKT'},
								{name: 'Geographic Markup Language - v2 (GML2)', fileExt: '.gml', mimeType: 'text/xml', formatter: 'OpenLayers.Format.GML'},
								{name: 'GeoJSON', fileExt: '.json', mimeType: 'text/plain', formatter: 'OpenLayers.Format.GeoJSON'},
                                                                {name: 'GPS Exchange Format (GPX)', fileExt: '.gpx', mimeType: 'text/xml', formatter: 'OpenLayers.Format.GPX', fileProjection: new OpenLayers.Projection('EPSG:4326')},
                                                                {name: 'Keyhole Markup Language (KML)', fileExt: '.kml', mimeType: 'text/xml', formatter: 'OpenLayers.Format.KML', fileProjection: new OpenLayers.Projection('EPSG:4326')},
                                                                {name: 'CSV (with X,Y in WGS84)', fileExt: '.csv', mimeType: 'text/plain', formatter: 'OpenLayers.Format.GeoJSON', fileProjection: new OpenLayers.Projection('EPSG:4326')},
                                                                {name: 'ESRI Shapefile (zipped, Google projection)', fileExt: '.zip', mimeType: 'text/plain', formatter: 'OpenLayers.Format.GeoJSON', fileProjection: new OpenLayers.Projection('EPSG:900913')},
                                                                {name: 'ESRI Shapefile (zipped, WGS84)', fileExt: '.zip', mimeType: 'text/plain', formatter: 'OpenLayers.Format.GeoJSON', fileProjection: new OpenLayers.Projection('EPSG:4326')},
                                                                {name: 'OGC GeoPackage (Google projection)', fileExt: '.gpkg', mimeType: 'text/plain', formatter: 'OpenLayers.Format.GeoJSON', fileProjection: new OpenLayers.Projection('EPSG:900913')},
                                                                {name: 'OGC GeoPackage (1 layer, WGS84)', fileExt: '.gpkg', mimeType: 'text/plain', formatter: 'OpenLayers.Format.GeoJSON', fileProjection: new OpenLayers.Projection('EPSG:4326')}

                                                        ],
							// For custom projections use Proj4.js
							fileProjection: new OpenLayers.Projection('EPSG:4326')
						}
					}
				}
			},
                        // search panel
                        // zeynel dağlı
                         {
                                type: "searchcenter",
                                // Options for SearchPanel window
                                options: {
                                    show: false,
                                    toggleGroup: "toolGroup",
                                    searchWindow: {
                                        x: 100,
                                        y: undefined,
                                        width: 320,
                                        height: 400,
                                        items: [
                                            Ostim.searchPanelConfig
                                        ]
                                    }
                                }
                            },
                            // search panel 2 test
                            // zeynel dağlı
                             {
                                    type: "searchcenterflow",
                                    // Options for SearchPanel window
                                    options: {
                                        show: false,
                                        toggleGroup: "toolGroup",
                                        searchWindow: {
                                            x: 100,
                                            y: undefined,
                                            width: 320,
                                            height: 400,
                                            items: [
                                                Ostim.searchPanelConfigFlow
                                            ]
                                        }
                                    }
                                }
                                                        
						]
					}
				},
                                {
					xtype: 'hr_zeynelinfopanel',
                                        //zeynel dağlı
                                        //featureTypeCondition: 'GIS_isim',
                                        //featureTypeCondition: 'AGIS_Kaucuk',
                                        //featureTypeCondition: 'esri_cities_12764',
                                        // zeynel dağlı
                                        featureCountCondition: 1,
					id: 'hr-zeynel-info',
					region: "west",
					border: true,
					collapsible: true,
					collapsed: true,
					height: 205,
                                        width: 500,
					split: false,
                                        showTopToolbar: true,
                                        displayPanels: ['Table'],
                                        //displayPanels: ['Grid', 'XML'],
                                                            // Export to download file. Option values are 'CSV', 'XLS', default is no export (results in no export menu).
                                        exportFormats: ['CSV', 'XLS', 'GMLv2', 'Shapefile', 'GeoJSON', 'WellKnownText'],
					maxFeatures: 10
				}
			]
		}
	]
};







</script>

 <!--<div id="mapdiv" style="margin: 30px"></div> -->     
        
        