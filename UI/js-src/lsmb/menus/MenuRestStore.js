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
            onChildrenChange: function (parentItem, newChildrenList) {
                newChildrenList.sort(function(a, b) {
                    return a.name > b.name;
                });
            },
            pasteItem: function(/*Item*/ childItem, /*Item*/ oldParentItem, /*Item*/ newParentItem,
                        /*Boolean*/ bCopy, /*int?*/ insertIndex, /*Item*/ before){
                // summary:
                //      Copy an item from one tree to another.
                //      Used in drag & drop. Icon should reflect this
                var store = this.store;
                when(parentTree.model.store.put({preferred: 1},{id:childItem.id}))
                    .then(function(result){
                        store.add({
                            id: childItem.id,
                            parent: 0,
                            args: childItem.args,
                            path: "0," + childItem.id,
                            position: store.data.length,
                            name: oldParentItem.label + " - " + childItem.label,
                            module: childItem.module
                        }, {id: childItem.id});
                    });
            }
        });
        var preftree = new Tree({
            model: prefModel,
            dndController: dndSource,
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
            },
            onKeyUp: function(evt){
                if ( evt.code == "Delete" || evt.Code == 'KeyX' && evt.ctrlKey) {
                    var node = this.selectedNode;
                    if ( !node.item.menu ) {
                        when(parentTree.model.store.put({preferred: 0},{id: node.item.id}))
                            .then(function (result){
                                node.tree.model.store.remove(node.item.id);
                            });
                    }
                }
            },
        }, 'prefTree'); // make sure you have a target HTML element with this id

        // Create context menu for tree
        var contextMenu = new Menu({
            targetNodeIds: [preftree.id],
            selector: ".dijitTreeNode"
        });
        // Drag away would be fine too
        contextMenu.addChild(new MenuItem({
            label: "Remove preference",
            onClick: function(evt){
                var node = dijit.byNode(this.getParent().currentTarget);
                if ( !node.item.menu ) {
                    when(parentTree.model.store.put({preferred: 0},{id: node.item.id}))
                        .then(function (result){
                            node.tree.model.store.remove(node.item.id);
                        });
                }
            }
        }));

        var restStore = new JsonRest({
            target:      "/api/menus",
            idProperty: "id",
        });
        var cacheStore = new Memory({
            idProperty: "id",
            put: function(object, options){
                // fire the onChildrenChange event
                this.onChildrenChange(object, object.children);
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
                        }, {id: item.id});
                    });
                }
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
            onClick: function (item) {
                // Get the URL from the item, and navigate to it
                location.hash = self._get_url(item);
            }
        }, 'menuTree'); // make sure you have a target HTML element with this id
        //TODO: Restore loading icon...
    }
 });
});
