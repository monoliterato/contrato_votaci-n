//versiones que aceptara este contrato

pragma solidity >=0.4.22 <0.6.0;

contract Votos {

//Dirección del creador

    address creador;

//Dirección asignada al ganador de la elección

    address public direccionGanadorElecciones;

//Conteo de votos del ganador

    uint public votosDelGanador;


    string public ganadorElecciones;

//Arrays para candidatos y votantes
    
    Ciudadano[] public votantes;
    Candidato[] public candidatos;

//Propiedades de ciudadanos y candidatos

    struct Ciudadano {
        string nombre;
        address direccionCiudadano;
        address voto;
        bool yaVoto;
    }
    
    struct Candidato {
        string nombre;
        address direccionCandidato;
        uint votos;
    }

/*La idea de usar el nombre del contrato como constructor quedó desactualizada y ahora se utiliza la palabra constructor
en este caso en particular su función es la de asignar la dirección del usuario que crea el contrato a la variable creador*/

    constructor() public {
        creador = msg.sender;
    }

//Modifier es un elemento que define condiciones que luego deben ser cumplidas por las funciones que las invoquen

    modifier soloCreador() {
        if(creador == msg.sender) {

//Linea que solo se usa para continuar con el programa
            _;
        } else {
            revert();
        }
    }

    modifier soloCiudadano() {
        bool esCiudadano = false;
        for(uint i = 0; i < votantes.length; i++) {
            if(msg.sender == votantes[i].direccionCiudadano) {
                esCiudadano = true;
            }
        }
        if(esCiudadano == true) {
    //Se continua        
            _;
        } else {
            revert();
        }
    }



/*Acá se crea el ciudadano solo este método solo puede invocarse por el creador obtiene los datos de
La dirección del ciudadano y su nombre. Ademas su creación es estampada con la dirección del creador del contrato*/


    function crearCiudadano(address _direccionCiudadano, string memory  _nombre) public soloCreador {
        votantes.push(Ciudadano({
				nombre: _nombre,
				direccionCiudadano: _direccionCiudadano,
				voto: msg.sender,
				yaVoto: false
			}));} 
    
 



//Este método solo puede ser invocado por un ciudadano e inicia con cero votos por defecto    
    
    function  crearCandidato(address _address, string memory  _nombre) public soloCiudadano{
        candidatos.push(Candidato({
				nombre: _nombre,
				direccionCandidato: _address,
				votos: 0
			}));
    }
    



/*Se empareja la direccion del ejecutante actual con la totalidad de votantes ademas de verificar que no haya votado previamente 
de cumplirse se sobreescribe la variable voto y se le asigna la dirección del candidato usado y se incrementa el contador
Se emparejan la totalidad de los candidatos con la dirección introducida requerida y se incrementa el conteo de votos del candidato elejido*/

    
    function Voto(address _direccionCandidato) public soloCiudadano {
        uint cantidadDeVotos = 0;
        for(uint i = 0; i < votantes.length; i++) {
            if(votantes[i].direccionCiudadano == msg.sender && votantes[i].yaVoto == false) {
                votantes[i].voto = _direccionCandidato;
                votantes[i].yaVoto = true;
                cantidadDeVotos += 1;
                for(uint j = 0; j < candidatos.length; j++) {
                    if(candidatos[j].direccionCandidato == _direccionCandidato) {
                        candidatos[j].votos += 1;
                    }
                }
            } else {
                if(votantes[i].yaVoto) {
                    cantidadDeVotos += 1;
                }
            }
        }
        if(cantidadDeVotos == votantes.length) {
            finEleccion();
        }
    }



//Método que solo puede ser invocado por el creador edita los campos que determina al ganador de las elecciones
    
    function finEleccion() public soloCreador {
        for(uint i = 0; i < candidatos.length; i++) {
            if(candidatos[i].votos > votosDelGanador) {
                direccionGanadorElecciones = candidatos[i].direccionCandidato;
                votosDelGanador = candidatos[i].votos;
                ganadorElecciones = candidatos[i].nombre;
            }
        }
    }


      
}