



#[test_only]
module web3contacts::web3contacts_tests;
// uncomment this line to import the module
 use web3contacts::web3contacts::{Self,State,Card,Profile};
use sui::test_scenario::{Self};
use sui::test_utils::assert_eq;
use sui::object::id_to_address;
use std::string::utf8;
use web3contacts::web3contacts::create_profile;
const ENotImplemented: u64 = 0;

#[test] 
fun test_create_profile() {
    let user=@0xa;
    let mut scenario_val=test_scenario::begin(user);
    let scenario= &mut scenario_val;

    web3contacts::init_for_testing(test_scenario::ctx(scenario));
    test_scenario::next_tx(scenario,user);
    let name=utf8(b"Alice1-test");
    let description=utf8(b"test description");
    {
        let mut state=test_scenario::take_shared<State>(scenario);
        web3contacts::create_profile
        (
            name,
            description,
            &mut state,
            test_scenario::ctx(scenario)
        );
        test_scenario::return_shared(state);
    };

    let tx=test_scenario::next_tx(scenario,user);
    let expected_no_events=1;
    assert_eq(
        test_scenario::num_user_events(&tx),
         expected_no_events
         );
    {
        let state = test_scenario::take_shared<State>(scenario);
        let profile =test_scenario::take_from_sender<Profile>(scenario);
        assert!(
            human_relations::check_has_profile( &state,user) == 
            option::some(object::id_to_address(object::borrow_id(&profile))),
            0
        );

        test_scenario::return_shared(state);
        test_scenario::return_to_sender(scenario,profile);

    };
    test_scenario::end(scenario_val);
}



