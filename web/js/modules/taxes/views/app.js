define([
	'Underscore',
	'Backbone',
    'modules/taxes/collections/rules',
    'modules/taxes/views/rule',
], function(_, Backbone, RulesCollection, RuleView){

    var rulesListView = Backbone.View.extend({
        el: $('#manage-taxes'),
        events: {
            'click #new-rule-btn': 'newRule',
            'click #save-btn': 'save',
            'change #price-inc-tax': 'changeTaxConfig'
        },
        initialize: function(){
            $('#new-rule-btn').button({
                icons: {primary: 'ui-icon-plus'}
            });

            $('#save-btn').button({
                icons: {primary: 'ui-icon-disk'}
            });

            this.rulesCollection = new RulesCollection;
            this.rulesCollection.on('add', this.render, this);
            this.rulesCollection.on('remove', this.render, this);
            this.rulesCollection.on('reset', this.render, this);
        },
        render: function(){
            $('#rules').empty();
            this.rulesCollection.each(function(rule){
                var view = new RuleView({model: rule});
                view.render().$el.appendTo('#rules');
            });
        },
        save: function() {
            console.log(JSON.stringify(this.rulesCollection.toJSON()));

            $.post(this.rulesCollection.url, {rules: this.rulesCollection.toJSON()}, function(response){
                app.view.rulesCollection.fetch();
            });
        },
        newRule: function(){
            console.log(arguments);
            this.rulesCollection.add();
        },
        changeTaxConfig: function(e){
            $.post('/plugin/shopping/run/setConfig', {config: {showPriceIncTax: e.target.checked ? 1 : 0}}) ;
        }
    })
	
	return rulesListView;
});