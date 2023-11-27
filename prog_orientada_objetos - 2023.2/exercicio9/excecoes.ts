//exceção q7
export class AplicacaoError extends Error{
    constructor(message: string) {
        super(message);
    }
}

//exceção q7
export class ContaInexistenteError extends AplicacaoError{
    constructor(message:string) {
        super(message);
    }
}

//exceção q7
export class SaldoInsuficienteError extends AplicacaoError{
    constructor(message) {
        super(message);
    }
}

//exceção q10
export class ValorInvalidoError extends AplicacaoError{
    constructor(message:string) {
        super(message);
    }
}

//exceção q12
export class PoupancaInvalidaError extends AplicacaoError{
    constructor(message:string) {
        super(message);
    }
}

export class ContaJaCadastradaError extends AplicacaoError{ // questão 13 - verificar se conta já esta cadastrada
    constructor(message:string) {
        super(message);
    }
}