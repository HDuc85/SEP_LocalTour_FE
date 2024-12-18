// class VMTileMap {
//   static String satellite = '''{
//     "version": 8,
//     "name": "street",
//     "metadata": {
//       "maputnik:license": "https://maps.vietmap.vn",
//       "maputnik:renderer": "mbgljs"
//     },
//     "sources": {
//       "vietmap": {
//         "type": "vector",
//         "tiles": [
//           "https://maps.vietmap.vn/api/maps/data/data-20230629/{z}/{x}/{y}.pbf?apikey=9e37b843f972388f80a9e51612cad4c1bc3877c71c107e46"
//         ],
//         "minzoom": 0,
//         "maxzoom": 20
//       },
//       "google-satellite": {
//         "type": "raster",
//         "tiles": [
//           "http://mt0.google.com/vt/lyrs=s&hl=en&x={x}&y={y}&z={z}"
//         ]
//       },
//
//       "maptiler-satellite": {
//         "type": "raster",
//         "tiles": [
//           "https://api.maptiler.com/maps/satellite/{z}/{x}/{y}@2x.jpg?key=krN3paz9Zcx3i362lQpn"
//         ]
//       }
//     },
//     "sprite": "https://maps.vietmap.vn/mt/styles/tm/sprite",
//     "glyphs": "https://maps.vietmap.vn/mt/fonts/{fontstack}/{range}.pbf",
//     "layers": [
//       {
//         "id": "layer_google_satellite",
//         "type": "raster",
//         "source": "google-satellite",
//         "minzoom": 0,
//         "maxzoom": 20
//       },
//       {
//         "id": "layer_maptiler_satellite",
//         "type": "raster",
//         "source": "maptiler-satellite",
//         "minzoom": 0,
//         "maxzoom": 17
//       },
//       {
//         "id": "vmroad_ferry",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_ferry",
//         "minzoom": 9,
//         "maxzoom": 24,
//         "filter": [
//           "all"
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(90, 166, 222, 1)",
//           "line-width": 1.5,
//           "line-dasharray": [
//             0.5,
//             1.5
//           ]
//         }
//       },
//       {
//         "id": "vmTunnel_moto_alley-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#b1b1b1",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 15,
//                 2
//               ],
//               [
//                 16,
//                 4
//               ],
//               [
//                 17,
//                 5
//               ],
//               [
//                 18,
//                 5.5
//               ],
//               [
//                 19,
//                 6
//               ],
//               [
//                 20,
//                 10
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmTunnel_moto_alley",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 15,
//                 2
//               ],
//               [
//                 16,
//                 4
//               ],
//               [
//                 17,
//                 5
//               ],
//               [
//                 18,
//                 5.5
//               ],
//               [
//                 19,
//                 6
//               ],
//               [
//                 20,
//                 10
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmTunnel_local-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#b1b1b1",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 2.7
//               ],
//               [
//                 15,
//                 5
//               ],
//               [
//                 16,
//                 8
//               ],
//               [
//                 17,
//                 8
//               ],
//               [
//                 18,
//                 10
//               ],
//               [
//                 19,
//                 12.5
//               ],
//               [
//                 20,
//                 18
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmTunnel_local",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 2.7
//               ],
//               [
//                 15,
//                 5
//               ],
//               [
//                 16,
//                 8
//               ],
//               [
//                 17,
//                 8
//               ],
//               [
//                 18,
//                 10
//               ],
//               [
//                 19,
//                 12.5
//               ],
//               [
//                 20,
//                 18
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmTunnel_connecting-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 10,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#b1b1b1",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 1.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 12
//               ],
//               [
//                 18,
//                 16
//               ],
//               [
//                 19,
//                 18
//               ],
//               [
//                 20,
//                 26
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmTunnel_connecting",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 10,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 1.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 12
//               ],
//               [
//                 18,
//                 16
//               ],
//               [
//                 19,
//                 18
//               ],
//               [
//                 20,
//                 26
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmTunnel_secondary_connecting-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 10,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#b1b1b1",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 1.5
//               ],
//               [
//                 10,
//                 1.5
//               ],
//               [
//                 11,
//                 2
//               ],
//               [
//                 12,
//                 3.2
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 1
//               ],
//               [
//                 17,
//                 15.5
//               ],
//               [
//                 18,
//                 22
//               ],
//               [
//                 19,
//                 28
//               ],
//               [
//                 20,
//                 40
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmTunnel_secondary_connecting",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 10,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 1.5
//               ],
//               [
//                 10,
//                 1.5
//               ],
//               [
//                 11,
//                 2
//               ],
//               [
//                 12,
//                 3.2
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 1
//               ],
//               [
//                 17,
//                 15.5
//               ],
//               [
//                 18,
//                 22
//               ],
//               [
//                 19,
//                 28
//               ],
//               [
//                 20,
//                 40
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmTunnel_secondary-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 7,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fea",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 0.2
//               ],
//               [
//                 10,
//                 0.5
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 2.5
//               ],
//               [
//                 13,
//                 2.5
//               ],
//               [
//                 14,
//                 5
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 60
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmTunnel_secondary",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 7,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fea",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 0.2
//               ],
//               [
//                 10,
//                 0.5
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 2.5
//               ],
//               [
//                 13,
//                 2.5
//               ],
//               [
//                 14,
//                 5
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 60
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmTunnel_major-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 7,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "butt"
//         },
//         "paint": {
//           "line-color": "#fea",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 0.2
//               ],
//               [
//                 10,
//                 0.5
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 2.5
//               ],
//               [
//                 13,
//                 2.5
//               ],
//               [
//                 14,
//                 5
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 60
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmTunnel_major",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 7,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "round"
//         },
//         "paint": {
//           "line-color": "#fea",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 0.2
//               ],
//               [
//                 10,
//                 0.5
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 2.5
//               ],
//               [
//                 13,
//                 2.5
//               ],
//               [
//                 14,
//                 5
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 60
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmTunnel_network_expressway-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 7,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 6,
//                 1
//               ],
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 1
//               ],
//               [
//                 10,
//                 1
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 3
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 5
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 12
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 27
//               ],
//               [
//                 19,
//                 40
//               ],
//               [
//                 20,
//                 80
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmTunnel_network_expressway",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 7,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             2
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 6,
//                 1
//               ],
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 1
//               ],
//               [
//                 10,
//                 1
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 3
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 5
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 12
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 27
//               ],
//               [
//                 19,
//                 40
//               ],
//               [
//                 20,
//                 80
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_9_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 1
//               ],
//               [
//                 16,
//                 5
//               ],
//               [
//                 17,
//                 6
//               ],
//               [
//                 18,
//                 6.5
//               ],
//               [
//                 19,
//                 7.5
//               ],
//               [
//                 20,
//                 12
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_7-8_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-opacity": 0.13,
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 3
//               ],
//               [
//                 15,
//                 5.5
//               ],
//               [
//                 16,
//                 9
//               ],
//               [
//                 17,
//                 9.5
//               ],
//               [
//                 18,
//                 11.5
//               ],
//               [
//                 19,
//                 14
//               ],
//               [
//                 20,
//                 20
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_6_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 11,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-opacity": 0.13,
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 1.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 6.5
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 13
//               ],
//               [
//                 18,
//                 17.5
//               ],
//               [
//                 19,
//                 20
//               ],
//               [
//                 20,
//                 28
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_5_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 11,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 9,
//                 1.5
//               ],
//               [
//                 10,
//                 1.5
//               ],
//               [
//                 11,
//                 2
//               ],
//               [
//                 12,
//                 3.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 8
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 24
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 42
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_4_border-14",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#e9ac77",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_2-3_border-12",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#e9ac77",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 4
//               ],
//               [
//                 13,
//                 5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_CT_border-14",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(252, 114, 0, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 23
//               ],
//               [
//                 18,
//                 32
//               ],
//               [
//                 19,
//                 45
//               ],
//               [
//                 20,
//                 86
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_9-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 15,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#B1B1B1",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 15,
//                 2
//               ],
//               [
//                 16,
//                 4.5
//               ],
//               [
//                 17,
//                 5.5
//               ],
//               [
//                 18,
//                 6
//               ],
//               [
//                 19,
//                 7
//               ],
//               [
//                 20,
//                 11
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmroad_9",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 15,
//                 2
//               ],
//               [
//                 16,
//                 4.5
//               ],
//               [
//                 17,
//                 5.5
//               ],
//               [
//                 18,
//                 6
//               ],
//               [
//                 19,
//                 7
//               ],
//               [
//                 20,
//                 11
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_7-8-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 1.5
//               ],
//               [
//                 14,
//                 3
//               ],
//               [
//                 15,
//                 5
//               ],
//               [
//                 16,
//                 7
//               ],
//               [
//                 17,
//                 8
//               ],
//               [
//                 18,
//                 9.5
//               ],
//               [
//                 19,
//                 12
//               ],
//               [
//                 20,
//                 18
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmroad_7-8",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 1.5
//               ],
//               [
//                 14,
//                 3
//               ],
//               [
//                 15,
//                 5
//               ],
//               [
//                 16,
//                 8
//               ],
//               [
//                 17,
//                 9
//               ],
//               [
//                 18,
//                 10.5
//               ],
//               [
//                 19,
//                 13
//               ],
//               [
//                 20,
//                 19
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_6-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 11,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 1.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 8
//               ],
//               [
//                 16,
//                 11
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmroad_6",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 11,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 1.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 8
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 12
//               ],
//               [
//                 18,
//                 16
//               ],
//               [
//                 19,
//                 18.5
//               ],
//               [
//                 20,
//                 26
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_5-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 8,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#b1b1b1",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 1.5
//               ],
//               [
//                 10,
//                 1.5
//               ],
//               [
//                 11,
//                 2
//               ],
//               [
//                 12,
//                 3.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 7.5
//               ],
//               [
//                 15,
//                 10
//               ],
//               [
//                 16,
//                 11.5
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 23
//               ],
//               [
//                 19,
//                 29
//               ],
//               [
//                 20,
//                 41
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmroad_5",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 8,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "bevel",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 1.5
//               ],
//               [
//                 10,
//                 1.5
//               ],
//               [
//                 11,
//                 2
//               ],
//               [
//                 12,
//                 3.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 7.5
//               ],
//               [
//                 15,
//                 10
//               ],
//               [
//                 16,
//                 11.5
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 23
//               ],
//               [
//                 19,
//                 29
//               ],
//               [
//                 20,
//                 41
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_4_border-8",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 7,
//         "maxzoom": 14,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "!=",
//             "prefix",
//             "Phà"
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#e9ac77",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 7,
//                 1
//               ],
//               [
//                 9,
//                 1.5
//               ],
//               [
//                 10,
//                 1.5
//               ],
//               [
//                 11,
//                 2.5
//               ],
//               [
//                 12,
//                 4
//               ],
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 7
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_4_border-to",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#e9ac77",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_4_border-from",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#e9ac77",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_4-tunnel",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 7,
//         "maxzoom": 14,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "!=",
//             "prefix",
//             "Phà"
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 1
//               ],
//               [
//                 10,
//                 1
//               ],
//               [
//                 11,
//                 1.5
//               ],
//               [
//                 12,
//                 3
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11.5
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 60
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_4-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#b1b1b1",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 0.2
//               ],
//               [
//                 10,
//                 0.5
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 3
//               ],
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11.5
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 62
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmroad_4",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 0.2
//               ],
//               [
//                 10,
//                 0.5
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 3
//               ],
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11.5
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 62
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_2-3_border-6",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 6,
//         "maxzoom": 12,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#e9ac77",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 6,
//                 1
//               ],
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1.5
//               ],
//               [
//                 9,
//                 1.5
//               ],
//               [
//                 10,
//                 1.5
//               ],
//               [
//                 11,
//                 2.5
//               ],
//               [
//                 12,
//                 4
//               ],
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 7
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_2_3_border-12-to",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#e9ac77",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_2-3_border-12-from",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#e9ac77",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_2-3_6-tunnel",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 6,
//         "maxzoom": 14,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "round"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 6,
//                 0.5
//               ],
//               [
//                 7,
//                 0.5
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 9,
//                 1
//               ],
//               [
//                 10,
//                 1
//               ],
//               [
//                 11,
//                 1.5
//               ],
//               [
//                 12,
//                 3
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 5
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 60
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_2-3-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "butt"
//         },
//         "paint": {
//           "line-color": "#b1b1b1",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 6,
//                 0.5
//               ],
//               [
//                 7,
//                 0.5
//               ],
//               [
//                 8,
//                 0.1
//               ],
//               [
//                 9,
//                 0.2
//               ],
//               [
//                 10,
//                 0.5
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 2.5
//               ],
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 62
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmroad_2-3",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "round"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 6,
//                 0.5
//               ],
//               [
//                 7,
//                 0.5
//               ],
//               [
//                 8,
//                 0.1
//               ],
//               [
//                 9,
//                 0.2
//               ],
//               [
//                 10,
//                 0.5
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 2.5
//               ],
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 62
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmroad_CT_border_7",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 7,
//         "maxzoom": 14,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(252, 114, 0, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 7,
//                 1.5
//               ],
//               [
//                 8,
//                 2
//               ],
//               [
//                 10,
//                 2
//               ],
//               [
//                 11,
//                 3
//               ],
//               [
//                 12,
//                 4.5
//               ],
//               [
//                 13,
//                 6
//               ],
//               [
//                 14,
//                 9
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_CT_border-14-to",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(252, 114, 0, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 23
//               ],
//               [
//                 18,
//                 32
//               ],
//               [
//                 19,
//                 45
//               ],
//               [
//                 20,
//                 86
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_CT_border-14-from",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "bevel",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(252, 114, 0, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 23
//               ],
//               [
//                 18,
//                 32
//               ],
//               [
//                 19,
//                 45
//               ],
//               [
//                 20,
//                 86
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_CT-7-14-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 6,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 6,
//                 1
//               ],
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 10,
//                 1
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 3
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 15,
//                 8
//               ],
//               [
//                 16,
//                 10
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmroad_CT-7",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 6,
//         "maxzoom": 14,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "!=",
//             "structure",
//             3
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "miter",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 6,
//                 1
//               ],
//               [
//                 7,
//                 1
//               ],
//               [
//                 8,
//                 1
//               ],
//               [
//                 10,
//                 1
//               ],
//               [
//                 11,
//                 1
//               ],
//               [
//                 12,
//                 3
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 5
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_CT-14",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "bevel",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 5
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 13
//               ],
//               [
//                 17,
//                 20
//               ],
//               [
//                 18,
//                 29
//               ],
//               [
//                 19,
//                 42
//               ],
//               [
//                 20,
//                 82
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_rail-casting",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_railway",
//         "minzoom": 8,
//         "maxzoom": 24,
//         "filter": [
//           "all"
//         ],
//         "layout": {
//           "visibility": "visible",
//           "line-cap": "round",
//           "line-join": "round",
//           "line-miter-limit": 2
//         },
//         "paint": {
//           "line-color": "rgba(126, 126, 126, 1)",
//           "line-width": {
//             "base": 1.4,
//             "stops": [
//               [
//                 7,
//                 0.4
//               ],
//               [
//                 8,
//                 0.75
//               ],
//               [
//                 9,
//                 1
//               ],
//               [
//                 10,
//                 0.5
//               ],
//               [
//                 11,
//                 0.6
//               ],
//               [
//                 12,
//                 0.5
//               ],
//               [
//                 13,
//                 0.7
//               ],
//               [
//                 14,
//                 0.7
//               ],
//               [
//                 15,
//                 0.7
//               ],
//               [
//                 16,
//                 0.7
//               ],
//               [
//                 17,
//                 0.7
//               ],
//               [
//                 18,
//                 0.7
//               ],
//               [
//                 19,
//                 0.7
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-gap-width": {
//             "stops": [
//               [
//                 7,
//                 0
//               ],
//               [
//                 8,
//                 0
//               ],
//               [
//                 9,
//                 0
//               ],
//               [
//                 10,
//                 1
//               ],
//               [
//                 11,
//                 1.5
//               ],
//               [
//                 12,
//                 1.8
//               ],
//               [
//                 13,
//                 2
//               ],
//               [
//                 14,
//                 2.5
//               ],
//               [
//                 15,
//                 2.8
//               ],
//               [
//                 16,
//                 3
//               ],
//               [
//                 17,
//                 3.5
//               ],
//               [
//                 18,
//                 4
//               ],
//               [
//                 19,
//                 5
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_rail",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_railway",
//         "minzoom": 8,
//         "maxzoom": 24,
//         "filter": [
//           "all"
//         ],
//         "layout": {
//           "visibility": "visible",
//           "line-cap": "butt",
//           "line-join": "round"
//         },
//         "paint": {
//           "line-color": "rgba(126, 126, 126, 1)",
//           "line-width": {
//             "base": 1.4,
//             "stops": [
//               [
//                 8,
//                 3
//               ],
//               [
//                 9,
//                 4
//               ],
//               [
//                 10,
//                 5
//               ],
//               [
//                 11,
//                 5.5
//               ],
//               [
//                 12,
//                 6
//               ],
//               [
//                 13,
//                 7
//               ],
//               [
//                 14,
//                 8
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 11
//               ],
//               [
//                 18,
//                 12
//               ],
//               [
//                 19,
//                 13
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             3
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_9_border_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 16,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 5
//               ],
//               [
//                 17,
//                 6
//               ],
//               [
//                 18,
//                 6.5
//               ],
//               [
//                 19,
//                 7.5
//               ],
//               [
//                 20,
//                 12
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_9_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 15,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 5
//               ],
//               [
//                 17,
//                 6
//               ],
//               [
//                 18,
//                 6.5
//               ],
//               [
//                 19,
//                 7.5
//               ],
//               [
//                 20,
//                 12
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_7-8_border_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-opacity": 0.13,
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 3
//               ],
//               [
//                 15,
//                 5.5
//               ],
//               [
//                 16,
//                 9
//               ],
//               [
//                 17,
//                 9.5
//               ],
//               [
//                 18,
//                 11.5
//               ],
//               [
//                 19,
//                 14
//               ],
//               [
//                 20,
//                 20
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_7-8_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-opacity": 0.13,
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 3
//               ],
//               [
//                 15,
//                 5.5
//               ],
//               [
//                 16,
//                 9
//               ],
//               [
//                 17,
//                 9.5
//               ],
//               [
//                 18,
//                 11.5
//               ],
//               [
//                 19,
//                 14
//               ],
//               [
//                 20,
//                 20
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_6_border_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-opacity": 0.13,
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 13
//               ],
//               [
//                 18,
//                 17.5
//               ],
//               [
//                 19,
//                 20
//               ],
//               [
//                 20,
//                 28
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_6_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-opacity": 0.13,
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 1.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 13
//               ],
//               [
//                 18,
//                 17.5
//               ],
//               [
//                 19,
//                 20
//               ],
//               [
//                 20,
//                 28
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_5_border_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 8.5
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 24
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 42
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_5_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "miter",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 8.5
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 24
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 42
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_4_border_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(226, 134, 54, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_4_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(226, 134, 54, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_2-3_border_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(226, 134, 54, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_2-3_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(226, 134, 54, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 4
//               ],
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_CT_border_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(232, 107, 3, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 23
//               ],
//               [
//                 18,
//                 32
//               ],
//               [
//                 19,
//                 45
//               ],
//               [
//                 20,
//                 86
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_CT_border",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(232, 107, 3, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 23
//               ],
//               [
//                 18,
//                 32
//               ],
//               [
//                 19,
//                 45
//               ],
//               [
//                 20,
//                 86
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_9-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 15,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 4
//               ],
//               [
//                 17,
//                 4.2
//               ],
//               [
//                 18,
//                 4.8
//               ],
//               [
//                 19,
//                 5.5
//               ],
//               [
//                 20,
//                 9.5
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_9",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 15,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 4
//               ],
//               [
//                 17,
//                 4.2
//               ],
//               [
//                 18,
//                 4.8
//               ],
//               [
//                 19,
//                 5.5
//               ],
//               [
//                 20,
//                 9.5
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_7-8-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 2
//               ],
//               [
//                 15,
//                 4.5
//               ],
//               [
//                 16,
//                 7.5
//               ],
//               [
//                 17,
//                 8
//               ],
//               [
//                 18,
//                 9.5
//               ],
//               [
//                 19,
//                 12
//               ],
//               [
//                 20,
//                 17.5
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_7-8",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 2
//               ],
//               [
//                 15,
//                 4.5
//               ],
//               [
//                 16,
//                 7.5
//               ],
//               [
//                 17,
//                 8
//               ],
//               [
//                 18,
//                 9.5
//               ],
//               [
//                 19,
//                 12
//               ],
//               [
//                 20,
//                 17.5
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_6-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 1.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 9.5
//               ],
//               [
//                 17,
//                 11.5
//               ],
//               [
//                 18,
//                 15.5
//               ],
//               [
//                 19,
//                 18
//               ],
//               [
//                 20,
//                 25.5
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_6",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 1.5
//               ],
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 9.5
//               ],
//               [
//                 17,
//                 11.5
//               ],
//               [
//                 18,
//                 15.5
//               ],
//               [
//                 19,
//                 18
//               ],
//               [
//                 20,
//                 25.5
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_5-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 10.5
//               ],
//               [
//                 17,
//                 15
//               ],
//               [
//                 18,
//                 21.5
//               ],
//               [
//                 19,
//                 27.5
//               ],
//               [
//                 20,
//                 39
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_5",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 10.5
//               ],
//               [
//                 17,
//                 15
//               ],
//               [
//                 18,
//                 21.5
//               ],
//               [
//                 19,
//                 27.5
//               ],
//               [
//                 20,
//                 39
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_4-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 8.5
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 24.5
//               ],
//               [
//                 19,
//                 28.5
//               ],
//               [
//                 20,
//                 60
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_4",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 8.5
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 24.5
//               ],
//               [
//                 19,
//                 28.5
//               ],
//               [
//                 20,
//                 60
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_2-3-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "butt"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 4
//               ],
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 24.5
//               ],
//               [
//                 19,
//                 28.5
//               ],
//               [
//                 20,
//                 60
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_2-3",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "round"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 12,
//                 4
//               ],
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 24.5
//               ],
//               [
//                 19,
//                 28.5
//               ],
//               [
//                 20,
//                 60
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_CT-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "stops": [
//               [
//                 13,
//                 2.5
//               ],
//               [
//                 14,
//                 4
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 27.5
//               ],
//               [
//                 19,
//                 39
//               ],
//               [
//                 20,
//                 78
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_CT",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "stops": [
//               [
//                 13,
//                 2.5
//               ],
//               [
//                 14,
//                 4
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 27.5
//               ],
//               [
//                 19,
//                 39
//               ],
//               [
//                 20,
//                 78
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_9_border_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 15,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 5
//               ],
//               [
//                 17,
//                 6
//               ],
//               [
//                 18,
//                 6.5
//               ],
//               [
//                 19,
//                 7.5
//               ],
//               [
//                 20,
//                 12
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_9_border_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 16,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 5
//               ],
//               [
//                 17,
//                 6
//               ],
//               [
//                 18,
//                 6.5
//               ],
//               [
//                 19,
//                 7.5
//               ],
//               [
//                 20,
//                 12
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_7-8_border_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "none"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-opacity": 0.13,
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 3
//               ],
//               [
//                 15,
//                 5.5
//               ],
//               [
//                 16,
//                 9
//               ],
//               [
//                 17,
//                 9.5
//               ],
//               [
//                 18,
//                 11.5
//               ],
//               [
//                 19,
//                 14
//               ],
//               [
//                 20,
//                 20
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_7-8_border_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-opacity": 0.13,
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 3
//               ],
//               [
//                 15,
//                 5.5
//               ],
//               [
//                 16,
//                 9
//               ],
//               [
//                 17,
//                 9.5
//               ],
//               [
//                 18,
//                 11.5
//               ],
//               [
//                 19,
//                 14
//               ],
//               [
//                 20,
//                 20
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_6_border_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-opacity": 0.13,
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 13
//               ],
//               [
//                 18,
//                 17.5
//               ],
//               [
//                 19,
//                 20
//               ],
//               [
//                 20,
//                 28
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_6_border_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-opacity": 0.13,
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 13
//               ],
//               [
//                 18,
//                 17.5
//               ],
//               [
//                 19,
//                 20
//               ],
//               [
//                 20,
//                 28
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_5_border_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "miter",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 8.5
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 24
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 42
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_5_border_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#ACACA9",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 8.5
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 24
//               ],
//               [
//                 19,
//                 30
//               ],
//               [
//                 20,
//                 42
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_4_border_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(226, 134, 54, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_4_border_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(226, 134, 54, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_2-3_border_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(226, 134, 54, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_2-3_border_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(226, 134, 54, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 28
//               ],
//               [
//                 19,
//                 32
//               ],
//               [
//                 20,
//                 65
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_CT_border_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(232, 107, 3, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 23
//               ],
//               [
//                 18,
//                 32
//               ],
//               [
//                 19,
//                 45
//               ],
//               [
//                 20,
//                 86
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_CT_border_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(232, 107, 3, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 23
//               ],
//               [
//                 18,
//                 32
//               ],
//               [
//                 19,
//                 45
//               ],
//               [
//                 20,
//                 86
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_9_To-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 15,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 4
//               ],
//               [
//                 17,
//                 4.2
//               ],
//               [
//                 18,
//                 4.8
//               ],
//               [
//                 19,
//                 5.5
//               ],
//               [
//                 20,
//                 9.5
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_9_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 15,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 4
//               ],
//               [
//                 17,
//                 4.2
//               ],
//               [
//                 18,
//                 4.8
//               ],
//               [
//                 19,
//                 5.5
//               ],
//               [
//                 20,
//                 9.5
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_9_From-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 16,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 4
//               ],
//               [
//                 17,
//                 4.2
//               ],
//               [
//                 18,
//                 4.8
//               ],
//               [
//                 19,
//                 5.2
//               ],
//               [
//                 20,
//                 9
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_9_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 16,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 4
//               ],
//               [
//                 17,
//                 4.2
//               ],
//               [
//                 18,
//                 4.8
//               ],
//               [
//                 19,
//                 5.2
//               ],
//               [
//                 20,
//                 9
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_7-8_To-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 2
//               ],
//               [
//                 15,
//                 4
//               ],
//               [
//                 16,
//                 7
//               ],
//               [
//                 17,
//                 7.5
//               ],
//               [
//                 18,
//                 9
//               ],
//               [
//                 19,
//                 11.25
//               ],
//               [
//                 20,
//                 16.5
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_7-8_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 2
//               ],
//               [
//                 15,
//                 4
//               ],
//               [
//                 16,
//                 7
//               ],
//               [
//                 17,
//                 7.5
//               ],
//               [
//                 18,
//                 9
//               ],
//               [
//                 19,
//                 11.25
//               ],
//               [
//                 20,
//                 16.5
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_7-8_From-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 2
//               ],
//               [
//                 15,
//                 4
//               ],
//               [
//                 16,
//                 7
//               ],
//               [
//                 17,
//                 7.5
//               ],
//               [
//                 18,
//                 9
//               ],
//               [
//                 19,
//                 11.25
//               ],
//               [
//                 20,
//                 16.5
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_7-8_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 2
//               ],
//               [
//                 15,
//                 4
//               ],
//               [
//                 16,
//                 7
//               ],
//               [
//                 17,
//                 7.5
//               ],
//               [
//                 18,
//                 9
//               ],
//               [
//                 19,
//                 11.25
//               ],
//               [
//                 20,
//                 16.5
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_6_To-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 9.5
//               ],
//               [
//                 17,
//                 11.5
//               ],
//               [
//                 18,
//                 15.5
//               ],
//               [
//                 19,
//                 18
//               ],
//               [
//                 20,
//                 25.5
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_6_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 9.5
//               ],
//               [
//                 17,
//                 11.5
//               ],
//               [
//                 18,
//                 15.5
//               ],
//               [
//                 19,
//                 18
//               ],
//               [
//                 20,
//                 25.5
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_6_From-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 9.5
//               ],
//               [
//                 17,
//                 11.5
//               ],
//               [
//                 18,
//                 15.5
//               ],
//               [
//                 19,
//                 18
//               ],
//               [
//                 20,
//                 25.5
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_6_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 9.5
//               ],
//               [
//                 17,
//                 11.5
//               ],
//               [
//                 18,
//                 15.5
//               ],
//               [
//                 19,
//                 18
//               ],
//               [
//                 20,
//                 25.5
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_5_To-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 10.5
//               ],
//               [
//                 17,
//                 15
//               ],
//               [
//                 18,
//                 21.5
//               ],
//               [
//                 19,
//                 27.5
//               ],
//               [
//                 20,
//                 39
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_5_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 10.5
//               ],
//               [
//                 17,
//                 15
//               ],
//               [
//                 18,
//                 21.5
//               ],
//               [
//                 19,
//                 27.5
//               ],
//               [
//                 20,
//                 39
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_5_From-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(177, 177, 177, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 10.5
//               ],
//               [
//                 17,
//                 15
//               ],
//               [
//                 18,
//                 21.5
//               ],
//               [
//                 19,
//                 27.5
//               ],
//               [
//                 20,
//                 39
//               ]
//             ]
//           },
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_5_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 10.5
//               ],
//               [
//                 17,
//                 15
//               ],
//               [
//                 18,
//                 21.5
//               ],
//               [
//                 19,
//                 27.5
//               ],
//               [
//                 20,
//                 39
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_4_To-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 29.5
//               ],
//               [
//                 20,
//                 61
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_4_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 29.5
//               ],
//               [
//                 20,
//                 61
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_4_From-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 29.5
//               ],
//               [
//                 20,
//                 61
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_4_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 29.5
//               ],
//               [
//                 20,
//                 61
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_2-3_To-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "butt"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 24.5
//               ],
//               [
//                 19,
//                 29.5
//               ],
//               [
//                 20,
//                 61
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_2-3_To",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "round"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 24.5
//               ],
//               [
//                 19,
//                 29.5
//               ],
//               [
//                 20,
//                 61
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_2-3_From-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "butt"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 24.5
//               ],
//               [
//                 19,
//                 29.5
//               ],
//               [
//                 20,
//                 61
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_2-3_From",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "round"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 24.5
//               ],
//               [
//                 19,
//                 29.5
//               ],
//               [
//                 20,
//                 61
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_CT_to-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "stops": [
//               [
//                 13,
//                 2.5
//               ],
//               [
//                 14,
//                 4
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 27.5
//               ],
//               [
//                 19,
//                 39
//               ],
//               [
//                 20,
//                 78
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_CT_to",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelto",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "stops": [
//               [
//                 13,
//                 2.5
//               ],
//               [
//                 14,
//                 4
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 27.5
//               ],
//               [
//                 19,
//                 39
//               ],
//               [
//                 20,
//                 78
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_CT_from-uncor",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             1
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "stops": [
//               [
//                 13,
//                 2.5
//               ],
//               [
//                 14,
//                 4
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 27.5
//               ],
//               [
//                 19,
//                 39
//               ],
//               [
//                 20,
//                 72
//               ]
//             ]
//           },
//           "line-opacity": 0.13,
//           "line-dasharray": [
//             0.05,
//             0.2
//           ]
//         }
//       },
//       {
//         "id": "vmBridge_CT_from",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "levelfrom",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "stops": [
//               [
//                 13,
//                 2.5
//               ],
//               [
//                 14,
//                 4
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 12.5
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 27.5
//               ],
//               [
//                 19,
//                 39
//               ],
//               [
//                 20,
//                 72
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_9_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 16,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             9
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 16,
//                 4
//               ],
//               [
//                 17,
//                 5
//               ],
//               [
//                 18,
//                 5.5
//               ],
//               [
//                 19,
//                 6
//               ],
//               [
//                 20,
//                 10
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_7-8_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             7,
//             8
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 2
//               ],
//               [
//                 15,
//                 4
//               ],
//               [
//                 16,
//                 7
//               ],
//               [
//                 17,
//                 7.5
//               ],
//               [
//                 18,
//                 9
//               ],
//               [
//                 19,
//                 11.25
//               ],
//               [
//                 20,
//                 16.5
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_6_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 7.5
//               ],
//               [
//                 16,
//                 9.5
//               ],
//               [
//                 17,
//                 11.5
//               ],
//               [
//                 18,
//                 15.5
//               ],
//               [
//                 19,
//                 18
//               ],
//               [
//                 20,
//                 25.5
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_5_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             5
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "butt",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "#fff",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 3.5
//               ],
//               [
//                 14,
//                 7
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 10.5
//               ],
//               [
//                 17,
//                 15
//               ],
//               [
//                 18,
//                 21.5
//               ],
//               [
//                 19,
//                 27.5
//               ],
//               [
//                 20,
//                 39
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmBridge_4_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 29.5
//               ],
//               [
//                 20,
//                 62
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_2-3_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible",
//           "line-cap": "round"
//         },
//         "paint": {
//           "line-color": "rgba(244, 224, 125, 1)",
//           "line-width": {
//             "base": 1.2,
//             "stops": [
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 6
//               ],
//               [
//                 15,
//                 9.5
//               ],
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 17
//               ],
//               [
//                 18,
//                 26
//               ],
//               [
//                 19,
//                 29.5
//               ],
//               [
//                 20,
//                 62
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmBridge_CT_roadtype",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_network",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "==",
//             "roadtype",
//             4
//           ],
//           [
//             "!has",
//             "prefix"
//           ],
//           [
//             "==",
//             "structure",
//             1
//           ],
//           [
//             "==",
//             "undercons",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(255, 147, 48, 1)",
//           "line-width": {
//             "stops": [
//               [
//                 13,
//                 4
//               ],
//               [
//                 14,
//                 4
//               ],
//               [
//                 15,
//                 9
//               ],
//               [
//                 16,
//                 12
//               ],
//               [
//                 17,
//                 19
//               ],
//               [
//                 18,
//                 27
//               ],
//               [
//                 19,
//                 40
//               ],
//               [
//                 20,
//                 80
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmadmin_province",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 4,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "class",
//             1,
//             2
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(85, 85, 85, 1)",
//           "line-opacity": 0.13,
//           "line-dasharray": {
//             "stops": [
//               [
//                 6,
//                 [
//                   1,
//                   1,
//                   1,
//                   1
//                 ]
//               ],
//               [
//                 7,
//                 [
//                   2,
//                   1,
//                   4,
//                   1
//                 ]
//               ],
//               [
//                 8,
//                 [
//                   2,
//                   2,
//                   6,
//                   1
//                 ]
//               ],
//               [
//                 9,
//                 [
//                   2,
//                   2,
//                   7,
//                   1
//                 ]
//               ],
//               [
//                 10,
//                 [
//                   2,
//                   2,
//                   10,
//                   1
//                 ]
//               ]
//             ]
//           },
//           "line-translate": [
//             0,
//             0
//           ],
//           "line-width": {
//             "stops": [
//               [
//                 4,
//                 0.5
//               ],
//               [
//                 10,
//                 0.8
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmadmin_district",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 9,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             3
//           ],
//           [
//             "!=",
//             "adminright",
//             "Đảo Trường Sa"
//           ],
//           [
//             "!=",
//             "adminright",
//             "Đảo Hoàng Sa"
//           ],
//           [
//             "has",
//             "adminleft"
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(102, 102, 102, 1)",
//           "line-dasharray": [
//             20,
//             5
//           ],
//           "line-width": {
//             "stops": [
//               [
//                 9,
//                 0.1
//               ],
//               [
//                 20,
//                 1
//               ]
//             ]
//           },
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmadmin_commune",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             4
//           ],
//           [
//             "has",
//             "adminleft"
//           ]
//         ],
//         "layout": {
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(136, 136, 136, 1)",
//           "line-dasharray": [
//             2,
//             2
//           ],
//           "line-width": 0.7,
//           "line-opacity": 0.13
//         }
//       },
//       {
//         "id": "vmwater_name",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "country_point",
//         "minzoom": 2,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ],
//           [
//             "==",
//             "class",
//             "ocean"
//           ]
//         ],
//         "layout": {
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Condensed Italic"
//           ],
//           "text-size": {
//             "stops": [
//               [
//                 2,
//                 10
//               ],
//               [
//                 3,
//                 12
//               ],
//               [
//                 4,
//                 15
//               ]
//             ]
//           },
//           "text-transform": "none",
//           "visibility": "visible",
//           "text-anchor": "center",
//           "text-max-width": {
//             "stops": [
//               [
//                 4,
//                 5
//               ],
//               [
//                 5,
//                 6.5
//               ]
//             ]
//           },
//           "text-justify": "center",
//           "text-pitch-alignment": "auto",
//           "text-rotation-alignment": "auto",
//           "text-letter-spacing": 0,
//           "text-keep-upright": false,
//           "text-allow-overlap": true
//         },
//         "paint": {
//           "text-color": "rgba(22, 108, 152, 1)",
//           "text-halo-blur": 1,
//           "text-halo-color": "rgba(53, 113, 142, 1)",
//           "text-halo-width": 0
//         }
//       },
//       {
//         "id": "vmpoi_priority-all",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_point",
//         "minzoom": 18,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ]
//         ],
//         "layout": {
//           "icon-image": "{class}",
//           "text-anchor": "left",
//           "text-field": "{shortname}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 7,
//           "text-size": 14,
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-size": 1,
//           "text-offset": [
//             1,
//             -1
//           ],
//           "icon-anchor": "bottom",
//           "text-justify": "left",
//           "text-line-height": 1,
//           "text-padding": 2,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "viewport",
//           "symbol-placement": "point",
//           "symbol-z-order": "auto"
//         },
//         "paint": {
//           "text-color": [
//             "get",
//             "color"
//           ],
//           "text-halo-blur": 0,
//           "text-halo-color": "#ffffff",
//           "text-halo-width": 2
//         }
//       },
//       {
//         "id": "vmpoi_priority-5",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_point",
//         "minzoom": 16,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ],
//           [
//             "!in",
//             "class",
//             "bus",
//             "hospital",
//             "bank",
//             "pagoda",
//             "church",
//             "committee",
//             "memorial",
//             "museum",
//             "parking",
//             "gasstation",
//             "company",
//             "other"
//           ]
//         ],
//         "layout": {
//           "icon-image": "{class}",
//           "text-anchor": "left",
//           "text-field": "{shortname}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 7,
//           "text-size": 14,
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-size": 1,
//           "text-offset": [
//             1,
//             -1
//           ],
//           "icon-anchor": "bottom",
//           "text-justify": "left",
//           "text-line-height": 1,
//           "text-padding": 2,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "viewport",
//           "symbol-placement": "point",
//           "symbol-z-order": "auto"
//         },
//         "paint": {
//           "text-color": [
//             "get",
//             "color"
//           ],
//           "text-halo-blur": 0,
//           "text-halo-color": "#ffffff",
//           "text-halo-width": 2
//         }
//       },
//       {
//         "id": "vmpoi_priority-4",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_point",
//         "minzoom": 15,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ],
//           [
//             "in",
//             "class",
//             "hospital",
//             "bank",
//             "pagoda",
//             "church"
//           ]
//         ],
//         "layout": {
//           "icon-image": "{class}",
//           "text-anchor": "left",
//           "text-field": "{shortname}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 7,
//           "text-size": 14,
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-size": 1,
//           "text-offset": [
//             1,
//             -1
//           ],
//           "icon-anchor": "bottom",
//           "text-justify": "left",
//           "text-line-height": 1,
//           "text-padding": 2,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "viewport",
//           "symbol-placement": "point",
//           "symbol-z-order": "auto"
//         },
//         "paint": {
//           "text-color": [
//             "get",
//             "color"
//           ],
//           "text-halo-blur": 0,
//           "text-halo-color": "#ffffff",
//           "text-halo-width": 2
//         }
//       },
//       {
//         "id": "vmpoi_priority-3",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_point",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ],
//           [
//             "in",
//             "class",
//             "hotel",
//             "memorial",
//             "museum",
//             "committee"
//           ]
//         ],
//         "layout": {
//           "icon-image": "{class}",
//           "text-anchor": "left",
//           "text-field": "{shortname}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 9,
//           "text-size": {
//             "stops": [
//               [
//                 13,
//                 10
//               ],
//               [
//                 16,
//                 14
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-size": 0.9,
//           "text-offset": [
//             1,
//             -1
//           ],
//           "icon-anchor": "bottom",
//           "text-justify": "left",
//           "text-line-height": 1,
//           "text-padding": 2,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "viewport",
//           "symbol-placement": "point",
//           "symbol-z-order": "auto",
//           "text-keep-upright": true,
//           "text-allow-overlap": false
//         },
//         "paint": {
//           "text-color": [
//             "get",
//             "color"
//           ],
//           "text-halo-blur": 0,
//           "text-halo-color": "#ffffff",
//           "text-halo-width": 2
//         }
//       },
//       {
//         "id": "vmpoi_priority-2",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_point",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ],
//           [
//             "in",
//             "class",
//             "parking",
//             "gasstation"
//           ]
//         ],
//         "layout": {
//           "icon-image": "{class}",
//           "text-anchor": "left",
//           "text-field": "{shortname}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 7,
//           "text-size": {
//             "stops": [
//               [
//                 12,
//                 10
//               ],
//               [
//                 15,
//                 16
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-size": 0.9,
//           "icon-anchor": "bottom",
//           "text-justify": "left",
//           "text-line-height": 1,
//           "text-padding": 2,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "viewport",
//           "symbol-placement": "point",
//           "symbol-z-order": "auto",
//           "text-keep-upright": true,
//           "text-allow-overlap": false,
//           "text-offset": [
//             1,
//             -1
//           ]
//         },
//         "paint": {
//           "text-color": [
//             "get",
//             "color"
//           ],
//           "text-halo-blur": 0,
//           "text-halo-color": "#ffffff",
//           "text-halo-width": 2
//         }
//       },
//       {
//         "id": "vmpoi_priority-1",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_point",
//         "minzoom": 11,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ],
//           [
//             "==",
//             "vm_class",
//             1
//           ],
//           [
//             "in",
//             "class",
//             "airport",
//             "harbor",
//             "rail"
//           ]
//         ],
//         "layout": {
//           "icon-image": "{class}",
//           "text-anchor": "left",
//           "text-field": "{shortname}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 7,
//           "text-size": {
//             "stops": [
//               [
//                 12,
//                 14
//               ],
//               [
//                 15,
//                 16
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": false,
//           "icon-size": 1,
//           "text-offset": [
//             1,
//             -1
//           ],
//           "icon-anchor": "bottom",
//           "text-justify": "left",
//           "text-line-height": 1,
//           "text-padding": 2,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "viewport",
//           "symbol-placement": "point",
//           "symbol-z-order": "auto",
//           "text-keep-upright": true,
//           "text-allow-overlap": {
//             "stops": [
//               [
//                 11,
//                 false
//               ],
//               [
//                 12,
//                 true
//               ],
//               [
//                 14,
//                 false
//               ]
//             ]
//           },
//           "icon-allow-overlap": false,
//           "icon-ignore-placement": false
//         },
//         "paint": {
//           "text-color": [
//             "get",
//             "color"
//           ],
//           "text-halo-blur": 0,
//           "text-halo-color": "#ffffff",
//           "text-halo-width": 2
//         }
//       },
//       {
//         "id": "vietmap_admin_commune_left",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 17,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             4
//           ],
//           [
//             "has",
//             "adminleft"
//           ],
//           [
//             "has",
//             "adminright"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{lprefix} {adminleft}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": 12,
//           "visibility": "visible",
//           "text-offset": [
//             0,
//             -1
//           ],
//           "text-allow-overlap": true,
//           "symbol-avoid-edges": true,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "icon-halo-blur": 2,
//           "icon-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 1.2,
//           "text-halo-color": "rgba(243, 243, 243, 1)",
//           "icon-color": "rgba(77, 77, 77, 1)"
//         }
//       },
//       {
//         "id": "vietmap_admin_commune_right",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 17,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             4
//           ],
//           [
//             "has",
//             "adminright"
//           ],
//           [
//             "has",
//             "adminleft"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{rprefix} {adminright}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": 12,
//           "visibility": "visible",
//           "text-offset": [
//             0,
//             1
//           ],
//           "text-allow-overlap": true,
//           "symbol-avoid-edges": true,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "icon-halo-blur": 2,
//           "icon-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 1.2,
//           "text-halo-color": "rgba(243, 243, 243, 1)",
//           "icon-color": "rgba(113, 110, 110, 1)"
//         }
//       },
//       {
//         "id": "vmroad_label_z16_",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 16,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "!in",
//             "prefix",
//             "Đường",
//             "Phố",
//             "Phà",
//             "Cầu"
//           ],
//           [
//             "!in",
//             "roadclass",
//             4,
//             5
//           ],
//           [
//             "has",
//             "prefix"
//           ],
//           [
//             "has",
//             "name"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{prefix} {name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "stops": [
//               [
//                 16,
//                 11
//               ],
//               [
//                 17,
//                 12
//               ],
//               [
//                 18,
//                 13
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map",
//           "symbol-spacing": {
//             "stops": [
//               [
//                 6,
//                 250
//               ],
//               [
//                 10,
//                 250
//               ]
//             ]
//           }
//         },
//         "paint": {
//           "text-color": "rgba(79, 79, 79, 1)",
//           "text-halo-blur": 0,
//           "text-halo-width": 1.2,
//           "text-halo-color": "rgba(255, 255, 255, 0.8)"
//         }
//       },
//       {
//         "id": "vmroad_label_z16_duong_pho",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             ">",
//             "roadclass",
//             6
//           ],
//           [
//             "in",
//             "prefix",
//             "Đường",
//             "Phố"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-size": {
//             "stops": [
//               [
//                 16,
//                 10
//               ],
//               [
//                 17,
//                 11
//               ],
//               [
//                 18,
//                 12
//               ]
//             ]
//           },
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(79, 79, 79, 1)",
//           "text-halo-blur": 0,
//           "text-halo-width": 1.2,
//           "text-halo-color": "rgba(255, 255, 255, 0.8)"
//         }
//       },
//       {
//         "id": "vmroad_label_z14_cau",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 14,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "prefix",
//             "Cầu"
//           ],
//           [
//             "<",
//             "roadclass",
//             7
//           ],
//           [
//             "has",
//             "name"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line",
//           "text-anchor": "center",
//           "text-field": "{prefix} {name}",
//           "text-font": [
//             "Roboto Medium"
//           ],
//           "text-size": {
//             "base": 1,
//             "stops": [
//               [
//                 14,
//                 10
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 13
//               ],
//               [
//                 17,
//                 15
//               ],
//               [
//                 18,
//                 16
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(71, 61, 80, 1)",
//           "text-halo-blur": 0,
//           "text-halo-width": 0.8,
//           "text-halo-color": "rgba(255, 255, 255, 0.8)"
//         }
//       },
//       {
//         "id": "vmroad_label_z13_",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "!in",
//             "prefix",
//             "Đường",
//             "Phố"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{routeno}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "base": 1,
//             "stops": [
//               [
//                 13,
//                 8
//               ],
//               [
//                 14,
//                 10
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(79, 79, 79, 1)",
//           "text-halo-blur": 0,
//           "text-halo-width": 1.2,
//           "text-halo-color": "rgba(255, 255, 255, 0.8)"
//         }
//       },
//       {
//         "id": "vmroad_label_local_z13_",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             6
//           ],
//           [
//             "in",
//             "prefix",
//             "Đường",
//             "Phố"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "stops": [
//               [
//                 13,
//                 8
//               ],
//               [
//                 14,
//                 10
//               ],
//               [
//                 15,
//                 11
//               ],
//               [
//                 16,
//                 12
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-allow-overlap": false,
//           "text-ignore-placement": false,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map",
//           "symbol-spacing": {
//             "stops": [
//               [
//                 16,
//                 300
//               ],
//               [
//                 20,
//                 700
//               ]
//             ]
//           }
//         },
//         "paint": {
//           "text-color": "rgba(79, 79, 79, 1)",
//           "text-halo-blur": 0,
//           "text-halo-width": 1.2,
//           "text-halo-color": "rgba(255, 255, 255, 0.8)"
//         }
//       },
//       {
//         "id": "vmroad_label_z12_",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 11,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4,
//             5
//           ],
//           [
//             "!in",
//             "prefix",
//             "Đường",
//             "Phố",
//             "Phà",
//             "Hầm"
//           ],
//           [
//             "has",
//             "name"
//           ],
//           [
//             "has",
//             "prefix"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line",
//           "text-anchor": "center",
//           "text-field": "{routeno}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "base": 1,
//             "stops": [
//               [
//                 12,
//                 12
//               ],
//               [
//                 13,
//                 13
//               ],
//               [
//                 14,
//                 14
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "text-halo-blur": 0,
//           "text-halo-width": 1.2,
//           "text-halo-color": "rgba(255, 255, 255, 0.8)"
//         }
//       },
//       {
//         "id": "vmroad_label_z12_duong_pho",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 10,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             4,
//             5
//           ],
//           [
//             "in",
//             "prefix",
//             "Đường",
//             "Phố"
//           ],
//           [
//             "has",
//             "name"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "base": 1,
//             "stops": [
//               [
//                 12,
//                 10
//               ],
//               [
//                 13,
//                 11
//               ],
//               [
//                 14,
//                 13
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map",
//           "text-justify": "center"
//         },
//         "paint": {
//           "text-color": "rgba(79, 79, 79, 1)",
//           "text-halo-blur": 0,
//           "text-halo-width": 1.2,
//           "text-halo-color": "rgba(255, 255, 255, 0.8)"
//         }
//       },
//       {
//         "id": "vmroad_label_z12_ham",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 11,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             2
//           ],
//           [
//             "==",
//             "prefix",
//             "Hầm"
//           ],
//           [
//             "has",
//             "name"
//           ],
//           [
//             "has",
//             "prefix"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{prefix} {name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "base": 1,
//             "stops": [
//               [
//                 12,
//                 12
//               ],
//               [
//                 13,
//                 13
//               ],
//               [
//                 14,
//                 14
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(79, 79, 79, 1)",
//           "text-halo-blur": 0,
//           "text-halo-width": 1.2,
//           "text-halo-color": "rgba(255, 255, 255, 0.8)"
//         }
//       },
//       {
//         "id": "vmroad_label_z9_pha",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_ferry",
//         "minzoom": 9,
//         "maxzoom": 24,
//         "filter": [
//           "all"
//         ],
//         "layout": {
//           "symbol-placement": "line",
//           "text-anchor": "center",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "base": 1,
//             "stops": [
//               [
//                 12,
//                 12
//               ],
//               [
//                 13,
//                 13
//               ],
//               [
//                 14,
//                 14
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "text-halo-blur": 0,
//           "text-halo-width": 1.2,
//           "text-halo-color": "rgba(255, 255, 255, 0.8)"
//         }
//       },
//       {
//         "id": "vmroad_shield",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 7,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "roadclass",
//             2,
//             3
//           ],
//           [
//             "has",
//             "routeno"
//           ],
//           [
//             "has",
//             "prefix"
//           ],
//           [
//             "in",
//             "prefix",
//             "QL",
//             "TL",
//             "HL",
//             "DT"
//           ],
//           [
//             "!in",
//             "routeno",
//             "CT.07",
//             "CT.03",
//             "CT.04",
//             "CT.01",
//             "CT.05",
//             "CT.14"
//           ]
//         ],
//         "layout": {
//           "icon-image": "highway",
//           "icon-rotation-alignment": "viewport",
//           "symbol-placement": "line-center",
//           "symbol-spacing": 500,
//           "text-field": "{routeno}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-rotation-alignment": "viewport",
//           "text-padding": 40,
//           "symbol-avoid-edges": false,
//           "text-max-width": 12,
//           "icon-size": 1,
//           "icon-text-fit": "both",
//           "text-size": {
//             "stops": [
//               [
//                 6,
//                 10
//               ],
//               [
//                 14,
//                 11
//               ],
//               [
//                 16,
//                 12
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "icon-text-fit-padding": [
//             3,
//             5,
//             1,
//             5
//           ],
//           "text-pitch-alignment": "viewport",
//           "symbol-z-order": "viewport-y",
//           "icon-pitch-alignment": "viewport"
//         },
//         "paint": {
//           "text-color": "rgba(10, 23, 183, 1)",
//           "text-opacity": 1,
//           "icon-translate-anchor": "viewport",
//           "text-translate-anchor": "viewport"
//         }
//       },
//       {
//         "id": "vmtoll",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_toll",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ]
//         ],
//         "layout": {
//           "text-anchor": "left",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 9,
//           "text-size": {
//             "stops": [
//               [
//                 12,
//                 14
//               ],
//               [
//                 15,
//                 11
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-size": {
//             "stops": [
//               [
//                 15,
//                 1
//               ],
//               [
//                 16,
//                 1.1
//               ]
//             ]
//           },
//           "text-line-height": 1,
//           "text-padding": 2,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "viewport",
//           "icon-image": "toll",
//           "text-offset": [
//             1,
//             -1
//           ],
//           "text-allow-overlap": false,
//           "icon-anchor": "bottom",
//           "text-ignore-placement": false,
//           "icon-allow-overlap": false,
//           "text-justify": "left"
//         },
//         "paint": {
//           "text-color": "rgba(64, 117, 255, 1)",
//           "text-halo-blur": 0.5,
//           "text-halo-color": "rgba(255, 252, 252, 1)",
//           "text-halo-width": 1,
//           "icon-opacity": 1,
//           "text-opacity": 1
//         }
//       },
//       {
//         "id": "vmfootprint_park_point-all",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_foot_print_point",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "!in",
//             "name",
//             "Honda Oto Mỹ Đình"
//           ],
//           [
//             "!=",
//             "showclass",
//             1
//           ]
//         ],
//         "layout": {
//           "text-anchor": "top",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 8,
//           "text-size": {
//             "base": 1.2,
//             "stops": [
//               [
//                 9,
//                 14
//               ],
//               [
//                 11,
//                 17
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-allow-overlap": false,
//           "symbol-placement": "point",
//           "icon-image": "national_parks",
//           "icon-anchor": "bottom",
//           "icon-size": {
//             "stops": [
//               [
//                 9,
//                 0.7
//               ],
//               [
//                 10,
//                 0.8
//               ],
//               [
//                 11,
//                 0.9
//               ],
//               [
//                 12,
//                 1
//               ]
//             ]
//           },
//           "text-justify": "center"
//         },
//         "paint": {
//           "text-color": "rgba(12, 138, 27, 1)",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": {
//             "stops": [
//               [
//                 8.99,
//                 0
//               ],
//               [
//                 9,
//                 1
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmfootprint_park_point",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_foot_print_point",
//         "minzoom": 8,
//         "maxzoom": 12,
//         "filter": [
//           "all",
//           [
//             "!in",
//             "name",
//             "Honda Oto Mỹ Đình"
//           ],
//           [
//             "==",
//             "showclass",
//             2
//           ],
//           [
//             ">",
//             "areageo",
//             200000000
//           ]
//         ],
//         "layout": {
//           "text-anchor": "top",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 8,
//           "text-size": {
//             "base": 1.2,
//             "stops": [
//               [
//                 9,
//                 14
//               ],
//               [
//                 11,
//                 17
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-allow-overlap": false,
//           "symbol-placement": "point",
//           "icon-image": "national_parks",
//           "icon-anchor": "bottom",
//           "icon-size": {
//             "stops": [
//               [
//                 9,
//                 0.7
//               ],
//               [
//                 10,
//                 0.8
//               ],
//               [
//                 11,
//                 0.9
//               ],
//               [
//                 12,
//                 1
//               ]
//             ]
//           },
//           "text-justify": "center"
//         },
//         "paint": {
//           "text-color": "rgba(12, 138, 27, 1)",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": {
//             "stops": [
//               [
//                 8.99,
//                 0
//               ],
//               [
//                 9,
//                 1
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmfootprint_park_point-national-park",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_foot_print_point",
//         "minzoom": 8,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "!in",
//             "name",
//             "Honda Oto Mỹ Đình"
//           ],
//           [
//             "==",
//             "showclass",
//             1
//           ]
//         ],
//         "layout": {
//           "text-anchor": "top",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 8,
//           "text-size": {
//             "base": 1.2,
//             "stops": [
//               [
//                 9,
//                 14
//               ],
//               [
//                 11,
//                 17
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-allow-overlap": false,
//           "symbol-placement": "point",
//           "icon-image": "national_parks",
//           "icon-anchor": "bottom",
//           "icon-size": {
//             "stops": [
//               [
//                 8,
//                 0.7
//               ],
//               [
//                 9,
//                 0.7
//               ],
//               [
//                 10,
//                 0.8
//               ],
//               [
//                 11,
//                 0.9
//               ],
//               [
//                 12,
//                 1
//               ]
//             ]
//           },
//           "text-justify": "center"
//         },
//         "paint": {
//           "text-color": "rgba(12, 138, 27, 1)",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": {
//             "stops": [
//               [
//                 8.99,
//                 0
//               ],
//               [
//                 9,
//                 1
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmhydro_centerline-3-4",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_hydro_centerline",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             ">=",
//             "dispclass",
//             3
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line",
//           "text-anchor": "center",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": 12,
//           "visibility": "visible",
//           "text-allow-overlap": false,
//           "text-ignore-placement": false,
//           "text-offset": [
//             1,
//             -0.5
//           ],
//           "text-line-height": 1.2,
//           "text-max-width": 10,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(52, 102, 168, 1)",
//           "icon-halo-blur": 2,
//           "icon-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 0,
//           "text-halo-color": "rgba(243, 243, 243, 1)"
//         }
//       },
//       {
//         "id": "vmhydro_centerline",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_hydro_centerline",
//         "minzoom": 9,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "dispclass",
//             1,
//             2
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line",
//           "text-anchor": "center",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": 12,
//           "visibility": "visible",
//           "text-allow-overlap": false,
//           "text-ignore-placement": false,
//           "text-offset": [
//             1,
//             -0.5
//           ],
//           "text-line-height": 1.2,
//           "text-max-width": 10,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(52, 102, 168, 1)",
//           "icon-halo-blur": 2,
//           "icon-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 0,
//           "text-halo-color": "rgba(243, 243, 243, 1)"
//         }
//       },
//       {
//         "id": "vm_island",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_island_point",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ]
//         ],
//         "layout": {
//           "icon-image": {
//             "base": 1,
//             "stops": [
//               [
//                 0,
//                 "dot_9"
//               ],
//               [
//                 8,
//                 ""
//               ]
//             ]
//           },
//           "text-anchor": "bottom",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 8,
//           "text-size": {
//             "stops": [
//               [
//                 9,
//                 11
//               ],
//               [
//                 20,
//                 16
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true
//         },
//         "paint": {
//           "text-color": "#333",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": 1
//         }
//       },
//       {
//         "id": "vm_village",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_point",
//         "minzoom": 13,
//         "maxzoom": 17,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             4
//           ]
//         ],
//         "layout": {
//           "text-field": "{abbrprefix} {name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 8,
//           "text-size": 15,
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-padding": 20
//         },
//         "paint": {
//           "text-color": "rgba(68, 68, 68, 1)",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2
//         }
//       },
//       {
//         "id": "vm_town-9",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_point",
//         "minzoom": 9,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             3
//           ]
//         ],
//         "layout": {
//           "icon-image": {
//             "base": 1,
//             "stops": [
//               [
//                 0,
//                 "dot_9"
//               ],
//               [
//                 8,
//                 ""
//               ]
//             ]
//           },
//           "text-anchor": "bottom",
//           "text-field": "{abbrprefix} {name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 8,
//           "text-size": {
//             "stops": [
//               [
//                 7,
//                 12
//               ],
//               [
//                 11,
//                 17
//               ],
//               [
//                 13,
//                 19
//               ],
//               [
//                 15,
//                 22
//               ],
//               [
//                 17,
//                 27
//               ],
//               [
//                 19,
//                 35
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-allow-overlap": true,
//           "text-allow-overlap": false
//         },
//         "paint": {
//           "text-color": "#333",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": 1
//         }
//       },
//       {
//         "id": "vm_town-7",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_point",
//         "minzoom": 7,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             3
//           ],
//           [
//             "in",
//             "prefix",
//             "Thành Phố",
//             "Thị Xã"
//           ]
//         ],
//         "layout": {
//           "icon-image": {
//             "base": 1,
//             "stops": [
//               [
//                 0,
//                 "dot_9"
//               ],
//               [
//                 8,
//                 ""
//               ]
//             ]
//           },
//           "text-anchor": "bottom",
//           "text-field": "{abbrprefix} {name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 8,
//           "text-size": {
//             "stops": [
//               [
//                 7,
//                 12
//               ],
//               [
//                 11,
//                 17
//               ],
//               [
//                 13,
//                 19
//               ],
//               [
//                 15,
//                 22
//               ],
//               [
//                 17,
//                 27
//               ],
//               [
//                 19,
//                 35
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-allow-overlap": true,
//           "text-allow-overlap": false
//         },
//         "paint": {
//           "text-color": "rgba(51, 51, 51, 1)",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": 1
//         }
//       },
//       {
//         "id": "vm_city",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_point",
//         "minzoom": 6,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             2
//           ]
//         ],
//         "layout": {
//           "icon-image": "province_dark-04",
//           "text-anchor": "center",
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-max-width": 20,
//           "text-offset": [
//             0,
//             -0.8
//           ],
//           "text-size": {
//             "base": 1.2,
//             "stops": [
//               [
//                 6,
//                 14
//               ],
//               [
//                 9,
//                 18
//               ],
//               [
//                 11,
//                 24
//               ],
//               [
//                 13,
//                 35
//               ]
//             ]
//           },
//           "icon-allow-overlap": true,
//           "icon-optional": false,
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-size": 0.5,
//           "icon-text-fit": "none"
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "text-halo-color": "rgba(255, 255, 255, 0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": {
//             "stops": [
//               [
//                 12,
//                 1
//               ],
//               [
//                 13,
//                 0.7
//               ],
//               [
//                 14,
//                 0.5
//               ],
//               [
//                 16,
//                 0
//               ]
//             ]
//           },
//           "icon-opacity": {
//             "stops": [
//               [
//                 6,
//                 0.5
//               ],
//               [
//                 10,
//                 0.5
//               ],
//               [
//                 11,
//                 0
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmroad_label_expressway",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             "has",
//             "name"
//           ],
//           [
//             "!=",
//             "prefix",
//             "Cầu"
//           ]
//         ],
//         "layout": {
//           "icon-rotation-alignment": "viewport",
//           "symbol-placement": {
//             "base": 1,
//             "stops": [
//               [
//                 7,
//                 "line"
//               ],
//               [
//                 11,
//                 "line"
//               ]
//             ]
//           },
//           "text-field": "{prefix} {name}",
//           "text-font": [
//             "Roboto Medium"
//           ],
//           "text-rotation-alignment": "map",
//           "symbol-avoid-edges": true,
//           "text-max-width": 100,
//           "text-size": {
//             "stops": [
//               [
//                 13,
//                 12
//               ],
//               [
//                 14,
//                 13
//               ],
//               [
//                 15,
//                 15
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "text-max-angle": 45,
//           "symbol-spacing": 100,
//           "text-allow-overlap": false,
//           "text-ignore-placement": false,
//           "text-padding": 40,
//           "symbol-z-order": "auto",
//           "text-pitch-alignment": "viewport"
//         },
//         "paint": {
//           "text-color": "rgba(50, 5, 21, 1)",
//           "text-translate-anchor": "viewport",
//           "text-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 1
//         }
//       },
//       {
//         "id": "vmroad_label_expressway-shell",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_network_name",
//         "minzoom": 7,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "roadclass",
//             1
//           ],
//           [
//             ">=",
//             "routeno",
//             "CT"
//           ],
//           [
//             "!=",
//             "prefix",
//             "Cầu"
//           ]
//         ],
//         "layout": {
//           "icon-rotation-alignment": "viewport",
//           "symbol-placement": {
//             "base": 1,
//             "stops": [
//               [
//                 7,
//                 "point"
//               ],
//               [
//                 8,
//                 "point"
//               ],
//               [
//                 9,
//                 "line"
//               ],
//               [
//                 13,
//                 "line"
//               ]
//             ]
//           },
//           "text-field": "{routeno}",
//           "text-font": [
//             "Roboto Medium"
//           ],
//           "text-rotation-alignment": "viewport",
//           "symbol-avoid-edges": true,
//           "text-max-width": 100,
//           "icon-text-fit": "both",
//           "text-size": 10,
//           "visibility": "visible",
//           "text-max-angle": 45,
//           "symbol-spacing": {
//             "stops": [
//               [
//                 7,
//                 100
//               ],
//               [
//                 8,
//                 5000
//               ]
//             ]
//           },
//           "icon-padding": 0,
//           "icon-optional": false,
//           "text-allow-overlap": false,
//           "text-ignore-placement": false,
//           "icon-image": "freeway",
//           "text-padding": 40,
//           "symbol-z-order": "auto",
//           "text-pitch-alignment": "viewport",
//           "icon-size": 1,
//           "icon-text-fit-padding": [
//             3,
//             5,
//             1,
//             5
//           ],
//           "icon-keep-upright": false,
//           "icon-pitch-alignment": "viewport",
//           "icon-allow-overlap": false,
//           "icon-ignore-placement": false
//         },
//         "paint": {
//           "text-color": "rgba(10, 23, 183, 1)",
//           "icon-translate-anchor": "viewport",
//           "text-translate-anchor": "viewport"
//         }
//       },
//       {
//         "id": "vm_big_city-HP-5",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_point",
//         "minzoom": 5,
//         "maxzoom": 8,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             1
//           ],
//           [
//             "==",
//             "name",
//             "Hải Phòng"
//           ]
//         ],
//         "layout": {
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "stops": [
//               [
//                 5,
//                 15
//               ],
//               [
//                 6,
//                 16
//               ],
//               [
//                 7,
//                 16
//               ],
//               [
//                 9,
//                 18
//               ]
//             ]
//           },
//           "text-transform": "none",
//           "visibility": "visible",
//           "text-allow-overlap": true,
//           "text-ignore-placement": false,
//           "text-padding": 2,
//           "text-anchor": "center",
//           "symbol-avoid-edges": false,
//           "text-letter-spacing": 0,
//           "text-max-width": 20,
//           "icon-image": "province_dark-04",
//           "icon-size": 0.6,
//           "text-offset": [
//             0,
//             1
//           ]
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": {
//             "stops": [
//               [
//                 12,
//                 1
//               ],
//               [
//                 13,
//                 0.7
//               ],
//               [
//                 14,
//                 0.5
//               ],
//               [
//                 16,
//                 0
//               ]
//             ]
//           },
//           "icon-opacity": {
//             "stops": [
//               [
//                 5,
//                 0.6
//               ],
//               [
//                 10,
//                 0.6
//               ],
//               [
//                 11,
//                 0
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vm_big_city-HP",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_point",
//         "minzoom": 5,
//         "maxzoom": 8,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             1
//           ],
//           [
//             "!=",
//             "name",
//             "Hà Nội"
//           ],
//           [
//             "!=",
//             "name",
//             "Hải Phòng"
//           ]
//         ],
//         "layout": {
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": 16,
//           "text-transform": "none",
//           "visibility": "visible",
//           "text-allow-overlap": true,
//           "text-ignore-placement": false,
//           "text-padding": 2,
//           "text-anchor": "center",
//           "symbol-avoid-edges": false,
//           "text-letter-spacing": 0,
//           "text-max-width": 20,
//           "text-offset": [
//             0,
//             -0.8
//           ],
//           "icon-image": "province_dark-04",
//           "icon-size": 0.6
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": {
//             "stops": [
//               [
//                 12,
//                 1
//               ],
//               [
//                 13,
//                 0.7
//               ],
//               [
//                 14,
//                 0.5
//               ],
//               [
//                 16,
//                 0
//               ]
//             ]
//           },
//           "icon-opacity": {
//             "stops": [
//               [
//                 6,
//                 0.6
//               ],
//               [
//                 10,
//                 0.6
//               ],
//               [
//                 11,
//                 0
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vm_big_city-HP-8",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_point",
//         "minzoom": 8,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             1
//           ],
//           [
//             "!=",
//             "name",
//             "Hà Nội"
//           ]
//         ],
//         "layout": {
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "stops": [
//               [
//                 6,
//                 16
//               ],
//               [
//                 7,
//                 16
//               ],
//               [
//                 9,
//                 18
//               ],
//               [
//                 11,
//                 24
//               ],
//               [
//                 13,
//                 35
//               ]
//             ]
//           },
//           "text-transform": "none",
//           "visibility": "visible",
//           "text-allow-overlap": true,
//           "text-ignore-placement": false,
//           "text-padding": 2,
//           "text-anchor": "center",
//           "symbol-avoid-edges": false,
//           "text-letter-spacing": 0,
//           "text-max-width": 8,
//           "text-offset": [
//             0,
//             -0.8
//           ],
//           "icon-image": "province_dark-04",
//           "icon-size": 0.6
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": {
//             "stops": [
//               [
//                 12,
//                 1
//               ],
//               [
//                 13,
//                 0.7
//               ],
//               [
//                 14,
//                 0.5
//               ],
//               [
//                 16,
//                 0
//               ]
//             ]
//           },
//           "icon-opacity": {
//             "stops": [
//               [
//                 6,
//                 0.6
//               ],
//               [
//                 10,
//                 0.6
//               ],
//               [
//                 11,
//                 0
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vm_hanoi",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_point",
//         "minzoom": 4,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "name",
//             "Hà Nội"
//           ]
//         ],
//         "layout": {
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Medium"
//           ],
//           "text-size": {
//             "stops": [
//               [
//                 4,
//                 15
//               ],
//               [
//                 6,
//                 20
//               ],
//               [
//                 10,
//                 22
//               ],
//               [
//                 13,
//                 35
//               ]
//             ]
//           },
//           "text-transform": "none",
//           "visibility": "visible",
//           "text-allow-overlap": false,
//           "text-ignore-placement": false,
//           "text-padding": 2,
//           "text-anchor": "top",
//           "symbol-avoid-edges": true,
//           "icon-size": {
//             "stops": [
//               [
//                 4,
//                 0.7
//               ],
//               [
//                 6,
//                 1
//               ]
//             ]
//           },
//           "text-justify": "center",
//           "text-offset": [
//             0,
//             -1
//           ],
//           "icon-offset": [
//             0,
//             6
//           ],
//           "icon-image": "capital"
//         },
//         "paint": {
//           "text-color": "#633",
//           "text-halo-color": "rgba(255,255,255,0.7)",
//           "text-halo-width": 1,
//           "icon-opacity": {
//             "stops": [
//               [
//                 10,
//                 1
//               ],
//               [
//                 11,
//                 0
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmcountry_1",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "country_point",
//         "minzoom": 4,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ],
//           [
//             "==",
//             "class",
//             "country"
//           ],
//           [
//             "!in",
//             "rank",
//             1,
//             2
//           ],
//           [
//             "!=",
//             "name",
//             "Scarborough Reef"
//           ]
//         ],
//         "layout": {
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Medium"
//           ],
//           "text-max-width": 6.25,
//           "text-size": {
//             "stops": [
//               [
//                 3,
//                 14
//               ],
//               [
//                 4,
//                 16
//               ],
//               [
//                 6,
//                 30
//               ],
//               [
//                 7,
//                 50
//               ],
//               [
//                 10,
//                 200
//               ]
//             ]
//           },
//           "text-transform": "none",
//           "symbol-avoid-edges": true,
//           "visibility": "visible",
//           "text-allow-overlap": false,
//           "text-padding": 0,
//           "text-anchor": "center",
//           "text-justify": "center"
//         },
//         "paint": {
//           "text-color": {
//             "stops": [
//               [
//                 5,
//                 "rgba(68, 68, 68, 1)"
//               ],
//               [
//                 10,
//                 "rgba(140, 140, 140, 1)"
//               ]
//             ]
//           },
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": {
//             "stops": [
//               [
//                 5,
//                 1
//               ],
//               [
//                 10,
//                 0.1
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmcountry_island",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "country_point",
//         "minzoom": 3,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ],
//           [
//             "==",
//             "rank",
//             2
//           ],
//           [
//             "==",
//             "class",
//             "island"
//           ]
//         ],
//         "layout": {
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Medium"
//           ],
//           "text-size": {
//             "stops": [
//               [
//                 1,
//                 5
//               ],
//               [
//                 3,
//                 10
//               ],
//               [
//                 4,
//                 12
//               ],
//               [
//                 6,
//                 20
//               ],
//               [
//                 8,
//                 70
//               ]
//             ]
//           },
//           "text-transform": "none",
//           "visibility": "none",
//           "symbol-avoid-edges": true,
//           "icon-allow-overlap": false,
//           "text-allow-overlap": true,
//           "text-padding": 0,
//           "text-line-height": {
//             "stops": [
//               [
//                 3,
//                 1
//               ],
//               [
//                 8,
//                 2
//               ]
//             ]
//           },
//           "symbol-spacing": 250,
//           "text-letter-spacing": {
//             "stops": [
//               [
//                 3,
//                 0
//               ],
//               [
//                 8,
//                 0.5
//               ]
//             ]
//           },
//           "text-max-width": {
//             "stops": [
//               [
//                 3,
//                 5
//               ],
//               [
//                 10,
//                 12
//               ]
//             ]
//           }
//         },
//         "paint": {
//           "text-color": "rgba(77, 77, 77, 1)",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": {
//             "stops": [
//               [
//                 6,
//                 1
//               ],
//               [
//                 10,
//                 0.1
//               ]
//             ]
//           }
//         }
//       },
//       {
//         "id": "vmcountry_vietnam_island",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "country_point",
//         "minzoom": 3,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ],
//           [
//             "in",
//             "rank",
//             1,
//             2
//           ],
//           [
//             "in",
//             "class",
//             "island"
//           ]
//         ],
//         "layout": {
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Medium"
//           ],
//           "text-size": {
//             "stops": [
//               [
//                 1,
//                 5
//               ],
//               [
//                 3,
//                 12
//               ],
//               [
//                 4,
//                 16
//               ],
//               [
//                 6,
//                 20
//               ],
//               [
//                 20,
//                 70
//               ]
//             ]
//           },
//           "text-transform": "none",
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "icon-allow-overlap": false,
//           "text-allow-overlap": true,
//           "text-padding": 0,
//           "text-line-height": {
//             "stops": [
//               [
//                 3,
//                 1
//               ],
//               [
//                 8,
//                 2
//               ]
//             ]
//           },
//           "symbol-spacing": 250,
//           "text-letter-spacing": {
//             "stops": [
//               [
//                 3,
//                 0
//               ],
//               [
//                 8,
//                 0.5
//               ]
//             ]
//           },
//           "text-max-width": {
//             "stops": [
//               [
//                 3,
//                 5
//               ],
//               [
//                 10,
//                 12
//               ]
//             ]
//           }
//         },
//         "paint": {
//           "text-color": "#333",
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1.2,
//           "text-opacity": 1
//         }
//       },
//       {
//         "id": "vmadmin_national_planet-shadow",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "planet_admin_line",
//         "maxzoom": 9,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(218, 218, 218, 1)",
//           "line-opacity": {
//             "base": 1,
//             "stops": [
//               [
//                 0,
//                 0.4
//               ],
//               [
//                 4,
//                 1
//               ]
//             ]
//           },
//           "line-width": {
//             "stops": [
//               [
//                 3,
//                 0.1
//               ],
//               [
//                 5,
//                 0.5
//               ],
//               [
//                 9,
//                 1
//               ]
//             ]
//           },
//           "line-offset": -1
//         }
//       },
//       {
//         "id": "vmadmin_national_planet",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "planet_admin_line",
//         "maxzoom": 9,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             0
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(125, 125, 125, 1)",
//           "line-opacity": {
//             "base": 1,
//             "stops": [
//               [
//                 0,
//                 0.4
//               ],
//               [
//                 4,
//                 1
//               ]
//             ]
//           },
//           "line-width": 1
//         }
//       },
//       {
//         "id": "vmadmin_national-shadow",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 9,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             0
//           ],
//           [
//             "!=",
//             "adminleft",
//             "Biển Đông"
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(223, 223, 223, 1)",
//           "line-opacity": {
//             "base": 1,
//             "stops": [
//               [
//                 0,
//                 0.4
//               ],
//               [
//                 4,
//                 1
//               ]
//             ]
//           },
//           "line-width": 2,
//           "line-offset": -1
//         }
//       },
//       {
//         "id": "vmadmin_national",
//         "type": "line",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 9,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             0
//           ],
//           [
//             "!=",
//             "adminleft",
//             "Biển Đông"
//           ]
//         ],
//         "layout": {
//           "line-cap": "round",
//           "line-join": "round",
//           "visibility": "visible"
//         },
//         "paint": {
//           "line-color": "rgba(141, 141, 141, 1)",
//           "line-opacity": {
//             "base": 1,
//             "stops": [
//               [
//                 0,
//                 0.4
//               ],
//               [
//                 4,
//                 1
//               ]
//             ]
//           },
//           "line-width": 1.5
//         }
//       },
//       {
//         "id": "vietmap_admin_district_right",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 15,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             3
//           ],
//           [
//             "has",
//             "adminleft"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line",
//           "text-anchor": "center",
//           "text-field": "{rprefix} {adminright}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": 12,
//           "visibility": "visible",
//           "text-offset": [
//             1,
//             1
//           ],
//           "text-allow-overlap": true,
//           "symbol-avoid-edges": true,
//           "text-ignore-placement": false,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map",
//           "symbol-spacing": {
//             "stops": [
//               [
//                 12,
//                 250
//               ],
//               [
//                 20,
//                 700
//               ]
//             ]
//           }
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "icon-halo-blur": 2,
//           "icon-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 2,
//           "text-halo-color": "rgba(243, 243, 243, 1)"
//         }
//       },
//       {
//         "id": "vietmap_admin_district_left",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 15,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             3
//           ],
//           [
//             "has",
//             "adminleft"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line",
//           "text-anchor": "center",
//           "text-field": "{lprefix} {adminleft}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": 12,
//           "visibility": "visible",
//           "text-offset": [
//             1,
//             -1
//           ],
//           "text-allow-overlap": true,
//           "symbol-avoid-edges": false,
//           "text-ignore-placement": false,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map",
//           "symbol-spacing": {
//             "stops": [
//               [
//                 12,
//                 250
//               ],
//               [
//                 20,
//                 700
//               ]
//             ]
//           }
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "icon-halo-blur": 2,
//           "icon-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 2,
//           "text-halo-color": "rgba(243, 243, 243, 1)",
//           "text-opacity": 1
//         }
//       },
//       {
//         "id": "vietmap_admin_province_right",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "class",
//             1,
//             2
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{rprefix} {adminright}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "base": 1,
//             "stops": [
//               [
//                 12,
//                 13
//               ],
//               [
//                 13,
//                 13
//               ],
//               [
//                 14,
//                 14
//               ],
//               [
//                 15,
//                 14
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 18
//               ],
//               [
//                 19,
//                 19
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "text-offset": [
//             1,
//             0.8
//           ],
//           "text-allow-overlap": true,
//           "symbol-avoid-edges": false,
//           "text-ignore-placement": false,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "icon-halo-blur": 2,
//           "icon-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 2,
//           "text-halo-color": "rgba(243, 243, 243, 1)"
//         }
//       },
//       {
//         "id": "vietmap_admin_province_left",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 13,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "in",
//             "class",
//             1,
//             2
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{lprefix} {adminleft}",
//           "text-font": [
//             "Roboto Regular"
//           ],
//           "text-size": {
//             "base": 1,
//             "stops": [
//               [
//                 12,
//                 13
//               ],
//               [
//                 13,
//                 13
//               ],
//               [
//                 14,
//                 14
//               ],
//               [
//                 15,
//                 14
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 18
//               ],
//               [
//                 19,
//                 19
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "text-offset": [
//             1,
//             -0.8
//           ],
//           "text-allow-overlap": true,
//           "symbol-avoid-edges": true,
//           "text-ignore-placement": false,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(0, 0, 0, 1)",
//           "icon-halo-blur": 2,
//           "icon-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 2,
//           "text-halo-color": "rgba(243, 243, 243, 1)"
//         }
//       },
//       {
//         "id": "vietmap_admin_national_left",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             0
//           ],
//           [
//             "!=",
//             "adminleft",
//             "Biển Đông"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{adminleft}",
//           "text-font": [
//             "Roboto Medium"
//           ],
//           "text-size": {
//             "base": 1,
//             "stops": [
//               [
//                 12,
//                 12
//               ],
//               [
//                 13,
//                 12
//               ],
//               [
//                 14,
//                 13
//               ],
//               [
//                 15,
//                 13
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 17
//               ],
//               [
//                 19,
//                 18
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "text-offset": [
//             1,
//             -0.8
//           ],
//           "text-allow-overlap": true,
//           "symbol-avoid-edges": false,
//           "text-ignore-placement": false,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(61, 61, 61, 1)",
//           "icon-halo-blur": 2,
//           "icon-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 2,
//           "text-halo-color": "rgba(243, 243, 243, 1)"
//         }
//       },
//       {
//         "id": "vietmap_admin_national_right",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "vietmap_admin_line",
//         "minzoom": 12,
//         "maxzoom": 24,
//         "filter": [
//           "all",
//           [
//             "==",
//             "class",
//             0
//           ],
//           [
//             "!=",
//             "adminleft",
//             "Biển Đông"
//           ]
//         ],
//         "layout": {
//           "symbol-placement": "line-center",
//           "text-anchor": "center",
//           "text-field": "{adminright}",
//           "text-font": [
//             "Roboto Medium"
//           ],
//           "text-size": {
//             "base": 1,
//             "stops": [
//               [
//                 12,
//                 12
//               ],
//               [
//                 13,
//                 12
//               ],
//               [
//                 14,
//                 13
//               ],
//               [
//                 15,
//                 13
//               ],
//               [
//                 16,
//                 15
//               ],
//               [
//                 17,
//                 16
//               ],
//               [
//                 18,
//                 17
//               ],
//               [
//                 19,
//                 18
//               ]
//             ]
//           },
//           "visibility": "visible",
//           "text-offset": [
//             1,
//             0.8
//           ],
//           "text-allow-overlap": true,
//           "text-ignore-placement": false,
//           "text-pitch-alignment": "viewport",
//           "text-rotation-alignment": "map"
//         },
//         "paint": {
//           "text-color": "rgba(61, 61, 61, 1)",
//           "icon-halo-blur": 2,
//           "icon-halo-color": "rgba(255, 255, 255, 1)",
//           "text-halo-width": 2,
//           "text-halo-color": "rgba(243, 243, 243, 1)"
//         }
//       },
//       {
//         "id": "vmcountry_vietnam",
//         "type": "symbol",
//         "source": "vietmap",
//         "source-layer": "country_point",
//         "minzoom": 2,
//         "maxzoom": 10,
//         "filter": [
//           "all",
//           [
//             "==",
//             "\$type",
//             "Point"
//           ],
//           [
//             "in",
//             "rank",
//             1,
//             2
//           ],
//           [
//             "in",
//             "class",
//             "country"
//           ]
//         ],
//         "layout": {
//           "text-field": "{name}",
//           "text-font": [
//             "Roboto Medium"
//           ],
//           "text-max-width": 6.25,
//           "text-size": {
//             "stops": [
//               [
//                 2,
//                 14
//               ],
//               [
//                 3,
//                 16
//               ],
//               [
//                 4,
//                 20
//               ],
//               [
//                 6,
//                 30
//               ],
//               [
//                 7,
//                 40
//               ],
//               [
//                 10,
//                 50
//               ]
//             ]
//           },
//           "text-transform": "none",
//           "visibility": "visible",
//           "symbol-avoid-edges": true,
//           "text-offset": [
//             0,
//             -0.7
//           ]
//         },
//         "paint": {
//           "text-color": {
//             "stops": [
//               [
//                 2,
//                 "rgba(94, 94, 94, 1)"
//               ],
//               [
//                 5,
//                 "rgba(68, 68, 68, 1)"
//               ]
//             ]
//           },
//           "text-halo-color": "rgba(255,255,255,0.8)",
//           "text-halo-width": 1,
//           "text-opacity": 1
//         }
//       }
//     ],
//     "id": "map-apis"
//   }''';
// }
