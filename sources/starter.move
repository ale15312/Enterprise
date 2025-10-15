module 0x0::inteligente {

    use sui::tx_context::TxContext;
    use sui::object;
    use sui::transfer;
    use std::string::String;

    public struct Vehiculo has store, drop, copy {
        placa: String,
        modelo: String,
    }

    public struct Estacionamiento has key {
        id: object::UID,
        nombre: String,
        espacios_totales: u16,
        espacios_ocupados: u16,
        vehiculos: vector<Vehiculo>, // Lista de vehículos
    }

    public fun crear_estacionamiento(nombre: String, espacios_totales: u16, ctx: &mut TxContext) {
        let estacionamiento = Estacionamiento {
            id: object::new(ctx),
            nombre,
            espacios_totales,
            espacios_ocupados: 0,
            vehiculos: vector::empty<Vehiculo>(),
        };
        transfer::transfer(estacionamiento, tx_context::sender(ctx));
    }

    public fun registrar_entrada(
        estacionamiento: &mut Estacionamiento,
        placa: String,
        modelo: String
    ) {
        assert!(estacionamiento.espacios_ocupados < estacionamiento.espacios_totales, 0);
        let vehiculo = Vehiculo { placa, modelo };
        vector::push_back(&mut estacionamiento.vehiculos, vehiculo);
        estacionamiento.espacios_ocupados = estacionamiento.espacios_ocupados + 1;
    }

    public fun registrar_salida(
        estacionamiento: &mut Estacionamiento,
        placa: String
    ) {
        let mut i = 0;
        let len = vector::length(&estacionamiento.vehiculos);
        while (i < len) {
            let v = &estacionamiento.vehiculos[i];
            if (v.placa == placa) {
                vector::swap_remove(&mut estacionamiento.vehiculos, i);
                estacionamiento.espacios_ocupados = estacionamiento.espacios_ocupados - 1;
                return
            };
            i = i + 1;
        }
    }

    public fun espacios_disponibles(estacionamiento: &Estacionamiento): u16 {
        estacionamiento.espacios_totales - estacionamiento.espacios_ocupados
    }

    public fun listar_vehiculos(estacionamiento: &Estacionamiento): vector<String> {
        let placas = vector::empty<String>();
        let mut i = 0;
        let len = vector::length(&estacionamiento.vehiculos);
        let mut placas_mut = placas;
        while (i < len) {
            let v = &estacionamiento.vehiculos[i];
            vector::push_back(&mut placas_mut, v.placa);
            i = i + 1;
        };
        placas_mut
    }
}

