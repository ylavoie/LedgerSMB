define(["dojo/_base/declare",
    "dojo/store/JsonRest", "dojo/store/Observable",
    "dojo/store/Memory", "lsmb/menus/Cache",
    "dijit/Tree", "dijit/tree/ObjectStoreModel",
    "dijit/Menu", "dijit/MenuSeparator",
    "dijit/MenuItem", "dijit/PopupMenuItem", "dijit/CheckedMenuItem",
    "dojo/when", "dojo/dom", "dijit/registry",
    "dijit/tree/dndSource", "dojo/Deferred",
    "dojo/ready"
], function(declare, JsonRest, Observable,
    Memory, Cache,
    Tree, ObjectStoreModel,
    Menu, MenuSeparator,
    MenuItem, PopupMenuItem, CheckedMenuItem,
    when, dom, registry,
    dndSource, Deferred,
){
  return declare(
    "lsmb/menus/MenuRestStore", [Menu], {
    parentTree: null,
    prefModel: null,
    _get_url: function (item) {
        var url = "";
        if ( item.module ) {
            url += item.module + "?login=" + dom.byId("login").textContent + "&";
            url += item.args.join("&");
        }
        url += ('New Window' == item.label) ? "&target='new'"
             : ('login.pl' == item.module)  ? "&target='_top'"
                                            : "";
        return url;
    },
    postCreate: function() {
        var self = this;
        // set up the store to get the tree data, plus define the method
        // to query the children of a node
        // give Observable interface so Tree can track updates
        var observableStore = new Observable(
            new Memory({
                idProperty: "id",
                getChildren: function(object) {
                    return this.query({
                        parent: object.id
                    });
                },
                data: [ // Set root
                {
                    id: "0", name: "Preferred menus", menu: 1
                }
            ]})
        );

        // create model to interface Tree to store
        prefModel = new ObjectStoreModel({
            store: observableStore,
            mayHaveChildren: function(object){
                // if true, we might be missing the data, false and nothing should be done
                return object["menu"] && ("children" in object) && object["children"] ;
            },
            pasteItem: function(/*Item*/ childItem, /*Item*/ oldParentItem, /*Item*/ newParentItem,
                        /*Boolean*/ bCopy, /*int?*/ insertIndex, /*Item*/ before){
                // summary:
                //      Copy an item from one tree to another.
                //      Used in drag & drop.

                this.store.add({
                    id: childItem.id,
                    parent: 0,
                    args: childItem.args,
                    path: "0," + childItem.id,
                    position: this.store.data.length,
                    name: oldParentItem.label + " - " + childItem.label,
                    module: childItem.module
                });
                parentTree.model.store.put(childItem.id, {preferred: 1});
            }
        });
        var preftree = new Tree({
            model: prefModel,
            dndController: dndSource,
            checkAcceptance: this.treeCheckAcceptance,
            showRoot: true,
            openOnClick: true,
            copyOnly: true,
            getIconClass: function(/*dojo.data.Item*/ item, /*Boolean*/ opened){
                return (!item || item.menu) ? (opened ? "dijitFolderOpened" : "dijitFolderClosed") : "dijitLeaf"
            },
            checkItemAcceptance: function(target, source, position){
                return typeof source.anchor.item.menu === 'undefined';    // Refuse menus
            },
            onClick: function (item) {
                // Get the URL from the item, and navigate to it
                location.hash = self._get_url(item);
            }
        }, 'prefTree'); // make sure you have a target HTML element with this id

        var restStore = new JsonRest({
            target:      "/menus",
            idProperty: "id",
            _getTarget: function(id){
                return this.target;
            },
        });
        var cacheStore = new Memory({
            idProperty: "id",
            put: function(object, options){
                // fire the onChildrenChange event
                this.onChildrenChange(object, object.children);
                // fire the onChange event
                this.onChange(object);
                // execute the default action
                return Memory.prototype.put.apply(this, arguments);
            },
            // we can also put event stubs so these methods can be
            // called before the listeners are applied
            onChildrenChange: function(item, children){
                // fired when the set of children for an object change
                //console.log(item);
                if ( item.preferred > 0 && item.parent) {
                    when(this.get(item.parent), function(object) {
                        prefModel.store.add({
                            parent: 0,
                            args: item.args,
                            position: prefModel.store.data.length,
                            name: object.label + " - " + item.label,
                            module: item.module
                        });
                    });
                }
            },
            onChange: function(object){
                // fired when the properties of an object change
            },
        });
        restStore = new Cache(restStore, cacheStore);

        // create model to interface Tree to store
        var restModel = new ObjectStoreModel({
            store: restStore,
            // Utility routines
            mayHaveChildren: function(object){
                // if true, we might be missing the data, false and nothing should be done
                return object["menu"] && ("children" in object) && object["children"] ;
            },
            getChildren: function(object, onComplete, onError){
                // Supply a getChildren() method to store for the data model where
                // children objects point to their parent (aka relational model)
                // return this.query({parent: this.getIdentity(object)});
                // That is the standard way but querying the cache will query JSON
                // If Cache were to be fixed, then we could simplify the
                // code below, rely on above mechanism and remove Perl & SQL routines
                var kids;
                if ( object.children ) {
                    kids = [];
                    for ( var i = 0 ; i < object.children.length ; i++ ) {
                        when(this.store.get(object.children[i]), function(item) {
                            kids.push(item);
                        });
                    }
                }
                onComplete(kids);
             },
            getRoot: function(onItem, onError){
                // get the root object, we will do a get() and callback the result
                when(this.store.get('0')).then(onItem, onError);
            },
            getLabel: function(object){
                // just get the name (note some models makes use of 'labelAttr' as opposed to simply returning the key 'name')
                return object.label;
            },
            onChildrenChange: function(/*===== parent, newChildrenList =====*/){
                // summary:
                //		Callback to do notifications about new, updated, or deleted items.
                // parent: dojo/data/Item
                // newChildrenList: Object[]
                //		Items from the store
                // tags:
                //		callback
                console.log("ObjectStoreModel onChildrenChange");
            },
        });
        var parentTree = new Tree({
            model: restModel,
            dndController: dndSource,
            showRoot: false,
            openOnClick: true,
            copyOnly: true,
            dragThreshold: 8,
            betweenThreshold: 5,
            singular: 1,
            getTooltip: function(item) {
                return "Drag to Prefered menu";
            },
            _createTreeNode: function(args){
                var tnode = new dijit._TreeNode(args);
                tnode.labelNode.innerHTML = args.label;
                return tnode;
            },
            checkAcceptance: function(/*===== source, nodes =====*/){
                return false;
            },
            getIconClass: function(/*dojo.data.Item*/ item, /*Boolean*/ opened){
                return (!item || item.menu) ? (opened ? "dijitFolderOpened" : "dijitFolderClosed") : "dijitLeaf"
            },
            onLoadDeferred: function(){
                console.debug("tree onLoad here!");
                // do work here
            },
            onClick: function (item) {
                // Get the URL from the item, and navigate to it
                location.hash = self._get_url(item);
            }
        }, 'menuTree'); // make sure you have a target HTML element with this id
/*
        // Create context menu for trees
        var contextMenu = new Menu({
            targetNodeIds: [preftree.id],
            selector: ".dijitTreeNode"
        });
        contextMenu.addChild(new MenuItem({
            label: "Remove preference",
            onClick: function(evt){
                var node = this.getParent().currentTarget;
                console.log("menu clicked for node ", node);
            }
        }));
*/
        //TODO: Restore loading icon...
    }
 });
});
