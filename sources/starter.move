module estacionamiento::inteligente {

    use sui::tx_context::{Self, TxContext};
    use sui::object;
    use sui::transfer;
    use std::string::{Self, String};
    use std::vec_map;

    public struct Vehiculo has drop, copy {
        placa: String,
        modelo: String,
    }

    public struct Estacionamiento has key {
        id: object::UID,
        nombre: String,
        espacios_totales: u16,
        espacios_ocupados: u16,
        vehiculos: vec_map::VecMap<String, Vehiculo>, // Mapa de placa → vehículo
    }

    public fun crear_estacionamiento(nombre: String, espacios_totales: u16, ctx: &mut TxContext) {
        let estacionamiento = Estacionamiento {
            id: object::new(ctx),
            nombre,
            espacios_totales,
            espacios_ocupados: 0,
            vehiculos: vec_map::empty(),
        };

        transfer::transfer(estacionamiento, tx_context::sender(ctx));
    }

    public fun registrar_entrada(
        estacionamiento: &mut Estacionamiento,
        placa: String,
        modelo: String
    ) {
        assert!(estacionamiento.espacios_ocupados < estacionamiento.espacios_totales, 0);

        let vehiculo = Vehiculo { placa: placa, modelo: modelo };
        vec_map::insert(&mut estacionamiento.vehiculos, placa, vehiculo);
        estacionamiento.espacios_ocupados = estacionamiento.espacios_ocupados + 1;
    }

    public fun registrar_salida(
        estacionamiento: &mut Estacionamiento,
        placa: String
    ) {
        let _ = vec_map::remove(&mut estacionamiento.vehiculos, placa);
        estacionamiento.espacios_ocupados = estacionamiento.espacios_ocupados - 1;
    }

    public fun espacios_disponibles(estacionamiento: &Estacionamiento): u16 {
        estacionamiento.espacios_totales - estacionamiento.espacios_ocupados
    }

    public fun listar_vehiculos(estacionamiento: &Estacionamiento): vector<String> {
        let placas = vec_map::keys(&estacionamiento.vehiculos);
        placas
    }
}

