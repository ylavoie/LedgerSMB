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
    postCreate: function() {
        // set up the store to get the tree data, plus define the method
        // to query the children of a node
        // give Observable interface so Tree can track updates
        var observableStore = new Observable(new Memory({idProperty: "id"}));

        // create model to interface Tree to store
        prefModel = new ObjectStoreModel({
            store: observableStore,
            mayHaveChildren: function(object){
                // if true, we might be missing the data, false and nothing should be done
                return object["menu"] && ("children" in object) && object["children"] ;
            },
            getChildren: function(object, onComplete, onError){
                // Supply a getChildren() method to store for the data model where
                // children objects point to their parent (aka relational model)
                when(this.store.get(object.children)).then(onComplete, onError);
//                return this.store.query({parent: this.getIdentity(object)});
             },
            getRoot: function(onItem, onError){
                // get the root object, we will do a get() and callback the result
                when(this.store.get('0')).then(onItem, onError);
            },
            getLabel: function(object){
                // just get the name (note some models makes use of 'labelAttr' as opposed to simply returning the key 'name')
                return object.label;
            },
            pasteItem: function(/*Item*/ childItem, /*Item*/ oldParentItem, /*Item*/ newParentItem,
                        /*Boolean*/ bCopy, /*int?*/ insertIndex, /*Item*/ before){
                // summary:
                //      Copy an item from one tree to another.
                //      Used in drag & drop.

                parentTree.model.store.put({id: childItem.id, preferred: 1});
                var parent = parentTree.model.store.get(childItem.parent);
                var item = Object.assign({
                    parent: 0,
                    path: "0," + childItem.id,
                    position: this.store.data.length,
                    label: parent.label + " - " + childItem.label
                }, childItem);
                this.store.put(item, {
                    overwrite: false,
                    parent: 0,
                });
            },
            /*
            put: function(object, options){
                // fire the onChildrenChange event
                this.onChildrenChange(object, object.children);
                // fire the onChange event
                this.onChange(object);
                // execute the default action
                return dojo.store.Memory.prototype.put.apply(this, arguments);
            },
            */
            // we can also put event stubs so these methods can be
            // called before the listeners are applied
            onChildrenChange: function(parent, children){
                // fired when the set of children for an object change
            },
            onChange: function(object){
                // fired when the properties of an object change
            },
        });
        prefModel.store.add({
            "id" : "0",
            "level" : "0",
            "position" : "0",
            "label" : "Preferred menus",
            "children" : [],
            "childs" : "0",
            "path" : "0",
            "parent" : null,
            "menu" : "1"
        });

        var preftree = new Tree({
            model: prefModel,
            dndController: dndSource,
            checkAcceptance: this.treeCheckAcceptance,
            checkItemAcceptance: this.treeCheckItemAcceptance,
            showRoot: true,
            openOnClick: true,
            getIconClass: function(/*dojo.data.Item*/ item, /*Boolean*/ opened){
                return (!item || item.menu || item.name == 'getRoot') ? (opened ? "dijitFolderOpened" : "dijitFolderClosed") : "dijitLeaf"
            },
            checkItemAcceptance: function(target, source, position){
                return source.anchor.item.menu != 1;    // Refuse menus
            },
        }, 'prefTree'); // make sure you have a target HTML element with this id
        preftree.startup();

        var restStore = new JsonRest({
            target:      "/menus",
            idProperty: "id",
            _getTarget: function(id){
                return this.target;
            },
        });
        var cacheStore = new Memory({idProperty: "id"});
        restStore = new Cache(restStore, cacheStore);
        restStore.query();

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
                            var url = "";
                            if ( item.module ) {
                                url += item.module + "?login=" + dom.byId("login").textContent + "&";
                                url += item.args.join("&");
                            }
                            url += ('New Window' == item.label) ? "&target='new'"
                                 : ('login.pl' == item.module)  ? "&target='_top'"
                                                                : "";
                            item.url = url;
                            kids.push(item);
                            if ( item.preferred > 0 ) {
                                var prefItem = Object.assign({
                                    parent: 0,
                                    path: "0," + item.id,
                                    position: prefModel.store.data.length,
                                    label: object.label + " - " + item.label
                                }, item);
                                prefModel.store.put(prefItem, {
                                    overwrite: false,
                                    parent: 0,
                                });
                            }
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
            getTooltip: function(item) {
                return "Prefered menu";
            },
            _createTreeNode: function(args){
                var tnode = new dijit._TreeNode(args);
                tnode.labelNode.innerHTML = args.label;

                if (!tnode.item.menu) {
//                  restStore.put(item);
                }
                return tnode;
            },
            checkAcceptance: function(/*===== source, nodes =====*/){
                return false;
            },
            getIconClass: function(/*dojo.data.Item*/ item, /*Boolean*/ opened){
                return (!item || item.menu) ? (opened ? "dijitFolderOpened" : "dijitFolderClosed") : "dijitLeaf"
            },
        }, 'menuTree'); // make sure you have a target HTML element with this id
        parentTree.startup();
        var root = observableStore.get('0');
        root.preferred = 0;
        observableStore.put(root);

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

        //TODO: Restore loading icon...
        var menuTree = new Menu({
            targetNodeIds: ['menuTree']
        });
        var prefMenu = new Menu({
            targetNodeIds: ['prefTree']
        });

        var menu = new Menu();
        menu.addchild(prefTree);
        menu.addChild(new MenuSeparator);
        menu.addchild(menuTree);

        dojo.connect(prefTree, "onClick", prefTree, function(item,nodeWidget,e){
            if( nodeWidget.isExpandable ) {
                this._onExpandoClick({node:nodeWidget});
            } else {
                location.hash = item.url;
            }
        });
        dojo.connect(parentTree, "onClick", parentTree, function(item,nodeWidget,e){
            if( nodeWidget.isExpandable ) {
                this._onExpandoClick({node:nodeWidget});
            } else {
                location.hash = item.url;
            }
        });
        return menu;
    }
 });
});
