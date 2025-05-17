module web3contacts::web3contacts {
use std::string;
use std::string::String;
use sui::transfer::transfer;
use sui::object::uid_to_inner;
use sui::object;
use sui::event;
use sui::display;
use sui::package;
use sui::display::update_version;
use sui::sui::SUI;
use sui::balance::{Self, Balance};
use sui::coin::{Self, Coin};
use sui::balance::value;
use sui::table::{Self, Table};
use sui::object::id_from_address;

//============================================================
//Dependencies
//============================================================

//============================================================
// Constants
//============================================================


//============================================================
// Error Codes
//============================================================
const ENotEnough : u64=0;
//不能作废证件
const ECARDNOTDISUSEED : u64=1;
//不能转让证件
const ECARDCANNOTTRANSFER : u64=2;

const EProfileExisted :u64=3;

//============================================================
// Structs
//============================================================
// 证件
public struct Card has key{
    id:UID,
    relations:String,
    cp:address,
    disuse:bool,
    description:String,
    image_url:String,

} 

//利润
public struct Profits has key {
    id:UID,
    price:u64,
    balance:Balance<SUI>,
}

//状态
public struct State has key{
    id:UID,
    users: Table<address, address>,
}
public struct Profile has key{
    id:UID,
    name:String,
    description:String,
}

 public struct AdminCap has key{
    id:UID,
}

//One-time-Witness for Human Relations
public struct WEB3CONTACTS has drop{    
}


//============================================================
// Event Structs
//============================================================
 public struct NFTMinted has copy,drop{
    id:ID,
    creator:address,
    nft:address,

}

public struct ProfileCreated has copy,drop{
    id:ID,
    owner:address,
 
}
//============================================================
// Init
//============================================================

fun init(otw: WEB3CONTACTS, ctx:&mut TxContext){
    let keys=vector[     
        b"relations".to_string(),
        b"cp".to_string(),
        b"disuse".to_string(),
        b"description".to_string(),
        b"image_url".to_string(),  
        
    ];
    let values=vector[ 
        b"{relations}".to_string(),
        b"{cp}".to_string(),
        b"{disuse}".to_string(),
        b"{description}".to_string(),
        b"{image_url}".to_string(), 

        ];

    let publisher= package::claim(otw,ctx);
    let mut  display=display::new_with_fields<Card>(
        &publisher,keys,values,ctx
        );
    display.update_version();
    transfer::public_transfer(publisher,ctx.sender());
    transfer::public_transfer(display,ctx.sender());

    let profits=Profits{
        id:object::new(ctx),
        price:1000-000-000,
        balance:balance::zero(),
    };
    transfer::share_object(profits);

    transfer::share_object(State{
        id:object::new(ctx),
        users:table::new(ctx)})   ;

    //Admin cap权限
    let admin=AdminCap{id:object::new(ctx)};
    transfer(admin,ctx.sender());
   
}



//============================================================
// Entry Functions
//============================================================

public entry fun create_profile(
    name:String,
    description:String,
    state:&mut State,
    ctx:&mut TxContext
){
    let owner=ctx.sender();
    assert!(!table::contains(&state.users,owner),EProfileExisted);
    let uid=object::new(ctx);
    let id =object::uid_to_inner(&uid);
    let obj_add= object::uid_to_address(&uid);
    let profile=Profile{
        id:uid,
        name:name,
        description:description,
     };
    
   transfer(profile,owner);
   table::add(&mut state.users,owner,obj_add);
    event::emit(ProfileCreated{
          id:id,
          owner:owner,
     });
}


public entry fun mint_cp_card(
    name:String,
    cpAddr:address,
    description:String,
    url:String,
    url_cp:String,
    ctx:&mut TxContext){
        new_card(name,cpAddr,description,url,ctx);
        new_card(name,ctx.sender(),description,url_cp,ctx);
    
}


 public entry fun new_card(name:String,cpAddr:address,description:String,url:String,ctx:&mut TxContext){

    let owner=ctx.sender();
    let uid=object::new(ctx);
    let id =object::uid_to_inner(&uid);
    let obj_add= object::uid_to_address(&uid);

    let cert=Card{
        id:uid,
        relations:name,
        cp:cpAddr,
        disuse:false,
        description:description,
        image_url:url,
     };
    
    event::emit(NFTMinted{
        id:id,
        creator:owner,
        nft:obj_add
    });
    transfer(cert,owner);

}



 public entry fun transfer_card(card: Card,ctx:&mut TxContext){
    let owner=ctx.sender();
    assert!(owner==card.cp,ECARDCANNOTTRANSFER);
    assert!(card.disuse==false,ECARDNOTDISUSEED);
    let addr=get_cp(&card);
    transfer(card,addr);
}
 


public entry fun disuse_card(card: &mut Card,ctx:&mut TxContext){
    //let owner=ctx.sender();
    assert!(card.disuse==false,ECARDNOTDISUSEED);
    card.disuse=true;
}

///收集利润，需要管理员权限’AdminCap‘
public entry fun collect_profits(
    _: &AdminCap,
    profits:&mut Profits,
    ctx:&mut TxContext
){
    let owner=ctx.sender();
    let amount=balance::value(&profits.balance);
    let profits=coin::take(&mut profits.balance, amount, ctx);

    transfer::public_transfer(profits,owner);
}


///设置价格，需要管理员权限’AdminCap‘
public entry fun set_profits_price(
    _: &AdminCap,
    profits:&mut Profits,
    new_price:u64,
    ctx:&mut TxContext
){
    profits.price=new_price;
}


//============================================================
// Getter Functions
//============================================================

public fun check_has_profile(
    state:&State,
    addr:address
):Option<address>{
    if (table::contains(&state.users,addr)){
        option::some(*table::borrow(&state.users,addr))
    }else{
        option::none()
    }
    
}


public fun get_relations(card:&Card):String{
     card.relations
}
public fun get_cp(card:&Card):address{
     card.cp
}
public fun get_disuse(card:&Card):bool{
     card.disuse
}
public fun get_description(card:&Card):String{
     card.description
}
public fun get_image_url(card:&Card):String{
     card.image_url
}




//============================================================
// Helper Functions
//============================================================

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(WEB3CONTACTS{}, ctx);
}


}