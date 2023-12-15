import { Perfil, Postagem, PostagemAvancada, RepositorioDePerfisArray, RepositorioDePostagensArray } from "./index";

class RedeSocial {
    private _repositorioDePerfis: RepositorioDePerfisArray = new RepositorioDePerfisArray();
    private _repositorioDePostagens: RepositorioDePostagensArray = new RepositorioDePostagensArray();

    get repositorioDePerfis(): RepositorioDePerfisArray {
        return this._repositorioDePerfis;
    }

    get respositorioDePostagens(): RepositorioDePostagensArray {
        return this._repositorioDePostagens;
    }

    incluirPerfil(perfil: Perfil){  
        this._repositorioDePerfis.incluirPerfil(perfil);
    }

    consultarPerfil(id?: number | undefined, nome?: string | undefined, email?: string | undefined): Perfil {  
        return this._repositorioDePerfis.consultarPerfil(id, nome, email);
    }

    incluirPostagem(postagem: Postagem){
        this._repositorioDePostagens.incluirPostagem(postagem);
    }

    consultarPostagem(id?: number | undefined, texto?: string | undefined, hashtag?: string | undefined, perfil?:  Perfil | undefined): Postagem[]{
        return this._repositorioDePostagens.consultarPostagem(id, texto, hashtag, perfil);
    }

    curtir(idPost: number): void {
        this.respositorioDePostagens.curtir(idPost)
    }

    descurtir(idPost: number): void {
        this.respositorioDePostagens.descurtir(idPost)
    }

    decrementar(postagem: PostagemAvancada): void {
        postagem.decrementarVisualizacoes();
    }

    exibirPostagensPorHashtag(hashtag: string): PostagemAvancada[] {
        return this.respositorioDePostagens.exibirPostagensPorHashtag(hashtag);
    }

    exibirPostagensPorPerfil(id: number): Postagem[]{
        return this.repositorioDePerfis.exibirPostagensPorPerfil(id)
    }

    exibirTodasAsPostagens(): string{
        return this.respositorioDePostagens.exibirTodasPostagens()
    }

    exibirPerfis(): string{
        return this.repositorioDePerfis.exibirTodosOsPerfis();
    }

    exibirPorPostagem(idPostagem?: number, texto?: string){
        return this.respositorioDePostagens.exibirPorPostagem(idPostagem, texto);
    }

    postagensPopulares(){
        return this.respositorioDePostagens.postagensPopulares()
    }

    excluirPostagem(idPostagem: number){
        return this.respositorioDePostagens.excluirPostagem(idPostagem)
    }

    editarNome(antigoNome: string, nomeNovo: string){
        return this.repositorioDePerfis.editarNome(antigoNome, nomeNovo)
    }

    editarEmail(antigoEmail: string, emailNovo: string){
        return this.repositorioDePerfis.editarEmail(antigoEmail, emailNovo)
    }
}
export{ RedeSocial };
