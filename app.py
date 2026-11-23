
import os
import mysql.connector
import bcrypt

from flask import Flask, redirect, request, render_template, session

app = Flask(__name__)

app.secret_key = os.getenv("SECRET_KEY", "vetcare_chave_secreta")


# CONEXÃO COM O MYSQL
def get_conn():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "vetcare")
    )
 

# PÁGINA PRINCIPAL
@app.route("/")
def home():
    return redirect("/login")


# CADASTRO DE USUÁRIOS
@app.route("/cadastro-conta", methods=["GET", "POST"])
def cadastro_conta():

    if request.method == "POST":

        usuario = request.form.get("user")
        email = request.form.get("email")
        senha = request.form.get("senha")
        tipo = "usuario"

        senha_hash = bcrypt.hashpw(
            senha.encode("utf-8"),
            bcrypt.gensalt()
        ).decode("utf-8")

        conn = get_conn()
        cur = conn.cursor()

        try:
            cur.execute("""
                INSERT INTO conta (user, email, tipo, senha)
                VALUES (%s, %s, %s, %s)
            """, (usuario, email, tipo, senha_hash))

            conn.commit()

        except mysql.connector.IntegrityError:
            return "Este e-mail já está cadastrado!"

        finally:
            cur.close()
            conn.close()

        return redirect("/login")

    return render_template("cadastro.html")


# LOGIN
@app.route("/login", methods=["GET", "POST"])
def login():

    if request.method == "POST":

        email = request.form.get("email")
        senha = request.form.get("senha")

        conn = get_conn()
        cur = conn.cursor(dictionary=True)

        cur.execute("""
            SELECT id, `user`, email, tipo, senha
            FROM conta
            WHERE email = %s
        """, (email,))

        usuario = cur.fetchone()

        cur.close()
        conn.close()

        if usuario and bcrypt.checkpw(
            senha.encode("utf-8"),
            usuario["senha"].encode("utf-8")
        ):

            session.clear()
            session["usuario_id"] = usuario["id"]
            session["usuario_nome"] = usuario["user"]
            session["usuario_email"] = usuario["email"]
            session["usuario_tipo"] = usuario["tipo"]

            return redirect("/inicio")

        return redirect("/login?erro=1")

    return render_template("login.html")


# INÍCIO
@app.route("/inicio")
def inicio():

    if "usuario_id" not in session:
        return redirect("/login")

    return render_template("inicio.html")


# ATENDIMENTOS
@app.route("/atendimentos")
def atendimentos():

    if "usuario_id" not in session:
        return redirect("/login")

    return render_template("atendimentos.html")


# TABELAS
@app.route("/tabelas")
def tabelas():

    if "usuario_id" not in session:
        return redirect("/login")

    conn = get_conn()
    cur = conn.cursor(dictionary=True)

    cur.execute("""
        SELECT id, responsavel, cpf, data_nascimento_responsavel
        FROM cadastro
    """)
    cadastros = cur.fetchall()

    cur.execute("""
        SELECT id, `user`, email, tipo
        FROM conta
    """)
    contas = cur.fetchall()

    cur.execute("""
        SELECT id, nome_pet, data_nascimento_animal,
        especie, tipo_consulta
        FROM agendamento
    """)
    agendamentos = cur.fetchall()

    cur.close()
    conn.close()

    return render_template(
        "tabelas.html",
        cadastros=cadastros,
        contas=contas,
        agendamentos=agendamentos
    )


# SAIR
@app.route("/logout")
def logout():

    session.clear()

    return redirect("/login")


if __name__ == "__main__":
    app.run(debug=True)
