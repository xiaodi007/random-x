/// Module: randomX
/// provides functions for performing random or weighted random selection from a vector. It includes four main functions:
/// choice: Selects a single element from a given vector of elements.
/// choices: Selects multiple elements from a given vector of elements.
/// weighted_choice: Selects a single element from a given vector of elements based on the corresponding weights.
/// weighted_choices: Selects multiple elements from a given vector of elements based on the corresponding weights.

module randomX::randomX {
    // use sui::transfer;
    use std::string;
    use sui::random;
    use std::debug;
    use sui::random::{Random};

public struct Rands has key {
 id: UID,
 owner: address,
 worlds: vector<u8>,
 hp: u8,
 items: vector<u8>,
 turn_begin: vector<u8>,
 turn_item: vector<u8>,
 ai_random:u8,
 player_random:u8,
 }

    /// Calculate the total weight
    fun calculate_total_weight(weights: &vector<u64>): u64 {
        let mut total_weight = 0u64;
        let mut i = 0;
        while (i < vector::length(weights)) {
            total_weight = total_weight + *vector::borrow(weights, i);
            i = i + 1;
        };
        total_weight
    }


fun choice<T: copy>(seq: &vector<T>, rng: &random::Random, ctx: &mut TxContext): T {
    // If the input vector is empty, abort the operation
    if (vector::is_empty(seq)) {
        abort 0
    };

    // Get the length of the vector
    let len = seq.length() as u64;

    // Initialize the random number generator
    let mut generator = random::new_generator(rng, ctx);

    // Generate a random index within the range of the vector's length
    let rand_index = random::generate_u64_in_range(&mut generator, 0, len - 1);

    // Return the element at the randomly selected index
    *vector::borrow(seq, rand_index)
}

fun choices<T: copy>(seq: &vector<T>, count: u64, rng: &random::Random, ctx: &mut TxContext): vector<T> {
    // If the input vector is empty, abort the operation
    if (vector::is_empty(seq)) {
        abort 0
    };

    // Get the length of the vector
    let len = seq.length() as u64;

    // Initialize the random number generator
    let mut generator = random::new_generator(rng, ctx);

    // Create an empty vector to store the results
    let mut results = vector::empty<T>();

    // Initialize a counter for the loop
    let mut i = 0;

    // Loop to select 'count' number of random elements
    while (i < count) {
        // Generate a random index within the range of the vector's length
        let rand_index = random::generate_u64_in_range(&mut generator, 0, len - 1);

        // Get the element at the randomly selected index
        let value = *vector::borrow(seq, rand_index);

        // Add the selected element to the results vector
        vector::push_back(&mut results, value);

        // Increment the counter
        i = i + 1;
    };

    // Return the vector of randomly selected elements
    results
}

    /// Select a single element from `seq` with weights `weights`
fun weighted_choice<T: copy>(seq: &vector<T>, weights: &vector<u64>, rng: &mut random::Random, ctx: &mut TxContext): T {
        assert!(vector::length(seq) == vector::length(weights), 0);
        let mut generator = random::new_generator(rng, ctx);

        let total_weight = calculate_total_weight(weights);
        let mut rand_value = random::generate_u64_in_range(&mut generator, 0, total_weight - 1);

        let mut i = 0;
        while (i < vector::length(seq)) {
            let weight = *vector::borrow(weights, i);
            if (rand_value < weight) {
                return *vector::borrow(seq, i)
            };
            rand_value = rand_value - weight;
            i = i + 1;
        };
        abort 1 // This should never happen
    }

    /// Select `count` elements from `seq` with weights `weights`
fun weighted_choices<T: copy>(seq: &vector<T>, weights: &vector<u64>, count: u64, rng: &mut random::Random, ctx: &mut TxContext): vector<T> {
        let mut results = vector::empty<T>();
        let mut i = 0;
        while (i < count) {
            let choice = weighted_choice(seq, weights, rng, ctx);
            vector::push_back(&mut results, choice);
            i = i + 1;
        };
        results
    }

    /// Generate a random permutation of `seq`
fun random_permutation<T: copy + drop>(seq: &vector<T>, rng: &mut random::Random, ctx: &mut TxContext): vector<T> {
    let mut shuffled_seq = *seq;
    let len = vector::length(&shuffled_seq);
    let mut generator = random::new_generator(rng, ctx);

    let mut i = 0;
    while (i < len) {
        let rand_index = random::generate_u64_in_range(&mut generator, i, len - 1);
        if (i != rand_index) {
            let temp = *vector::borrow(&shuffled_seq, i);
            *vector::borrow_mut(&mut shuffled_seq, i) = *vector::borrow(&shuffled_seq, rand_index);
            *vector::borrow_mut(&mut shuffled_seq, rand_index) = temp;
        };
        i = i + 1;
    };

    shuffled_seq
}

    fun weighted_random_permutation<T: copy + drop>(seq: &vector<T>, weights: &vector<u64>, rng: &mut random::Random, ctx: &mut TxContext): vector<T> {
        assert!(vector::length(seq) == vector::length(weights), 0);

        let mut shuffled_seq = vector::empty<T>();
        let mut temp_seq = *seq;
        let mut temp_weights = *weights;

        let len = vector::length(&temp_seq);
        let mut i = 0;

        while (i < len) {
            let choice = weighted_choice(&temp_seq, &temp_weights, rng, ctx);
            vector::push_back(&mut shuffled_seq, choice);

            let mut index_to_remove = 0;
            while (index_to_remove < vector::length(&temp_seq)) {
                if (*vector::borrow(&temp_seq, index_to_remove) == choice) {
                    break;
                };
                index_to_remove = index_to_remove + 1;
            };

            vector::remove(&mut temp_seq, index_to_remove);
            vector::remove(&mut temp_weights, index_to_remove);
            i = i + 1;
        };

        shuffled_seq
    }

fun sample_without_replacement<T: copy + drop>(seq: &vector<T>, count: u64, rng: &mut random::Random, ctx: &mut TxContext): vector<T> {
    assert!(count <= vector::length(seq), 0);
    let mut generator = random::new_generator(rng, ctx);
    let mut temp_seq = *seq;
    let mut sampled_seq = vector::empty<T>();

    let mut i = 0;
    while (i < count) {
        let rand_index = random::generate_u64_in_range(&mut generator, 0, vector::length(&temp_seq) - 1);
        let choice = *vector::borrow(&temp_seq, rand_index);
        vector::push_back(&mut sampled_seq, choice);
        vector::remove(&mut temp_seq, rand_index);
        i = i + 1;
    };

    sampled_seq
}

public fun weighted_sample_without_replacement<T: copy + drop>(seq: &vector<T>, weights: &vector<u64>, count: u64, rng: &mut random::Random, ctx: &mut TxContext): vector<T> {
    assert!(vector::length(seq) == vector::length(weights), 0);
    assert!(count <= vector::length(seq), 0);

    let mut temp_seq = *seq;
    let mut temp_weights = *weights;
    let mut sampled_seq = vector::empty<T>();

    let mut i = 0;
    while (i < count) {
        let choice = weighted_choice(&temp_seq, &temp_weights, rng, ctx);
        vector::push_back(&mut sampled_seq, choice);

        let mut index_to_remove = 0;
        while (index_to_remove < vector::length(&temp_seq)) {
            if (*vector::borrow(&temp_seq, index_to_remove) == choice) {
                break;
            };
            index_to_remove = index_to_remove + 1;
        };

        vector::remove(&mut temp_seq, index_to_remove);
        vector::remove(&mut temp_weights, index_to_remove);
        i = i + 1;
    };

    sampled_seq
}

entry fun rollDice(rng: &Random, ctx: &mut TxContext) {
    // Define vectors representing dice, worlds, world selection, hp, and items
    let dice = vector[1u8, 2u8, 3u8, 4u8, 5u8, 6u8];
    let worlds = vector[1u8, 2u8, 3u8, 4u8, 5u8, 6u8, 7u8, 8u8];
    let world = vector[0u8, 1u8];
    let hp = vector[1u8, 2u8, 3u8, 4u8];
    let item = vector[1u8, 2u8, 3u8, 4u8, 5u8];

    // Randomly select a number of worlds
    let worlds_num = randomX::randomX::choice(&worlds, rng, ctx);
    
    // Select a number of worlds based on the previously selected number
    let world_vec = randomX::randomX::choices(&world, worlds_num as u64, rng, ctx);
    
    // Randomly select a hp value
    let hps = randomX::randomX::choice(&hp, rng, ctx);
    
    // Randomly select 8 items
    let item_vec = randomX::randomX::choices(&item, 8u64, rng, ctx);
    
    // Randomly select 2 dice for the first play
    let first_play = randomX::randomX::choices(&dice, 2u64, rng, ctx);
    
    // Randomly select 2 dice for the first item
    let first_item = randomX::randomX::choices(&dice, 2u64, rng, ctx);
    
    // Initialize the random number generator
    let mut generator = random::new_generator(rng, ctx);
    
    // Generate a random number for the AI
    let ai_random = random::generate_u8(&mut generator);
    
    // Generate a random number for the player
    let player_random = random::generate_u8(&mut generator);

    // Transfer the created object
    transfer::share_object(
        Rands {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            worlds: world_vec,
            hp: hps,
            items: item_vec,
            turn_begin: first_play,
            turn_item: first_item,
            ai_random: ai_random,
            player_random: player_random,
        }
    )
}


#[test]
fun test_x() {
    use sui::test_scenario as ts;
    use std::string;

    let user0 = @0x0;
    let mut ts = ts::begin(user0);

    random::create_for_testing(ts.ctx());
    ts.next_tx(user0);
    let mut random_state: random::Random = ts.take_shared();

    let u8_vector = vector[10u8, 20u8, 30u8, 40u8, 50u8];

    let u8_weights = vector[1, 2, 3, 4, 5];

    let sigle_choice_u8 = randomX::randomX::choice(&u8_vector, &mut random_state, ts.ctx());
    debug::print(&sigle_choice_u8);

    let many_choice_u8 = randomX::randomX::choices(&u8_vector, 2, &mut random_state, ts.ctx());
    debug::print(&many_choice_u8);

    let choice_u8 = randomX::randomX::weighted_choice(&u8_vector, &u8_weights, &mut random_state, ts.ctx());
    debug::print(&choice_u8);

    let choices_u8 = randomX::randomX::weighted_choices(&u8_vector, &u8_weights, 2, &mut random_state, ts.ctx());
    debug::print(&choices_u8);

    let string_vector = vector[string::utf8(b"hello"), string::utf8(b"world"), string::utf8(b"sui"), string::utf8(b"random")];

    let string_weights = vector[4, 1, 3, 5];

    let choice_string = randomX::randomX::weighted_choice(&string_vector, &string_weights, &mut random_state, ts.ctx());
    debug::print(&choice_string);

    let choices_string = randomX::randomX::weighted_choices(&string_vector, &string_weights, 5, &mut random_state, ts.ctx());
    debug::print(&choices_string);

    let shuffled_u8 = randomX::randomX::random_permutation(&u8_vector, &mut random_state, ts.ctx());
    debug::print(&shuffled_u8);

    let weighted_shuffled_u8 = randomX::randomX::weighted_random_permutation(&u8_vector, &u8_weights, &mut random_state, ts.ctx());
    debug::print(&weighted_shuffled_u8);

    let sampled_u8 = randomX::randomX::sample_without_replacement(&u8_vector, 2, &mut random_state, ts.ctx());
    debug::print(&sampled_u8);

     let weighted_sampled_u8 = randomX::randomX::weighted_sample_without_replacement(&u8_vector, &u8_weights, 2, &mut random_state, ts.ctx());
    debug::print(&weighted_sampled_u8);

    ts::return_shared(random_state);
    ts.end();
}
}







