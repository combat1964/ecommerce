define([
	'Underscore',
	'Backbone',
    'modules/zones/models/zone'
], function(_, Backbone, ZoneModel){

    var zoneCollection = Backbone.Collection.extend({
        model: ZoneModel,
        url: $('#websiteUrl').val()+'plugin/shopping/run/getdata/type/zones'
    });

	return zoneCollection;
});