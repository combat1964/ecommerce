define([
	'Underscore',
	'Backbone',
    'modules/people/collections/customers',
    'modules/people/views/customer_row',
    'modules/people/models/customer',
], function(_, Backbone, CustomersCollection, CustomerRowView, CustomerModel){

    var AppView = Backbone.View.extend({
        el: $('#people'),
        events: {
            'click #export-users': function(){ $('#expusrs').submit(); },
            'click #people-previous': 'goPreviousPage',
            'click #people-next': 'goNextPage',
            'click th.sortable': 'sort',
            'click #customer-details div.toolbar a:first': function() {$('#people-table,#customer-details').toggle()},
            'change #people-check-all': 'toggleAllPeople',
            'change select#mass-action': 'doAction',
            'keyup #people-search': 'searchPeople'
        },
        initialize: function(){
            $('#customer-details').hide();
            this.customers = new CustomersCollection();
            this.customers.on('reset', this.render, this);
            this.customers.fetch();
        },
        render: function(){
            $('#customer-list').empty();
            this.customers.each(function(customer){
                var view = new CustomerRowView({model: customer});
                view.render().$el.appendTo('#customer-list');
            });
        },
        goPreviousPage: function() {
            this.customers.previous();
            return false;
        },
        goNextPage: function() {
            this.customers.next();
            return false;
        },
        sort: function(e) {
            var $el = $(e.target)
                key = $el.data('sortkey');

            $el.siblings('.sortable').removeClass('sortUp').removeClass('sortDown');

            if (!!key) {
                this.customers.order.by = key;
                if (!$el.hasClass('sortUp') && !$el.hasClass('sortDown')){
                    $el.addClass('sortUp');
                    this.customers.order.asc = true;
                } else  {
                    $el.toggleClass('sortUp').toggleClass('sortDown');
                    this.customers.order.asc = !this.customers.order.asc;
                }
                this.customers.fetch()
            }
        },
        showCustomerDetails: function(uid) {
            $.get($('#website_url').val()+'plugin/shopping/run/profile/', {id: uid}, this.renderCustomerDetails);
        },
        renderCustomerDetails: function(response, status) {
            if (status === "success") {
                $('#people-table').hide();
                $('#customer-details').find('#profile').html(response).end().show();
            }
        },
        toggleAllPeople: function(e) {
            var value = e.target.checked;
            this.customers.each(function(customer){
                customer.set({checked: value});
            });
        },
        doAction: function(e){
            var method = $(e.target).val();

            method = this[method]
            if (_.isFunction(method)){
                method.call(this);
            }
            $(e.target).val(0);
        },
        deleteSelected: function(){
            var checked = this.customers.checked();
            if (_.isEmpty(checked)){
                return false;
            }
            showConfirm('Are you sure?', function(){
                var ids = _(checked).pluck('id');
            });

        },
        searchPeople: function(e){
            var term = e.target.value,
                self = this;

            clearTimeout(self.searching);
            self.searching = setTimeout(function(){
                self.customers.search(term);
            }, 600);
        }
    });
	
	return AppView;
});