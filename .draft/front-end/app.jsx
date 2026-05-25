// FODUN — Main app with screen routing

const { useState } = React;

function App() {
  const [authed, setAuthed] = useState(false);
  const [user, setUser] = useState("");
  const [screen, setScreen] = useState("login"); // login | register | sedes | detalle | misReservas | actualizar
  const [selectedSede, setSelectedSede] = useState(null);
  const [habDetail, setHabDetail] = useState(null);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [reservaData, setReservaData] = useState({});

  const onLogin = (doc) => {
    setUser("Alexander Jovel");
    setAuthed(true);
    setScreen("sedes");
  };
  const onLogout = () => {
    setAuthed(false);
    setUser("");
    setScreen("login");
  };

  const goSedes = () => { setSelectedSede(null); setScreen("sedes"); };
  const selectSede = (s) => {
    if (!authed) { setScreen("login"); return; }
    setSelectedSede(s);
    setScreen("detalle");
  };
  const openReservar = () => {
    setReservaData({
      llegada: "2026-06-15", salida: "2026-06-18",
      noches: 3, personas: 4, lavanderia: true,
      numHabs: 1, diasOrd: 2, diasEsp: 1,
      tOrd: 200000, tEsp: 120000, tLav: 45000,
      valorTotal: 365000
    });
    setConfirmOpen(true);
  };
  const confirmReserva = () => {
    setConfirmOpen(false);
    alert("✓ Reserva confirmada. Su comprobante de pago aparecerá en 'Mis Reservas'.");
    setScreen("misReservas");
  };

  return (
    <div className="app">
      <Header />
      <Nav screen={screen} setScreen={setScreen} authed={authed} user={user} onLogout={onLogout} />

      {screen === "login" && !authed && (
        <ScreenLogin onLogin={onLogin} onGoRegister={() => setScreen("register")} />
      )}
      {screen === "register" && !authed && (
        <ScreenRegistro
          onCancel={() => setScreen("login")}
          onRegistered={(name) => {
            setUser(name);
            setAuthed(true);
            setScreen("sedes");
            alert("✓ Registro exitoso. Bienvenido " + name);
          }}
        />
      )}
      {screen === "sedes" && (
        <ScreenSedes onSelect={selectSede} authed={authed} />
      )}
      {screen === "detalle" && selectedSede && (
        <ScreenDetalle
          sede={selectedSede}
          onBack={goSedes}
          onReservar={openReservar}
          onVerDetalle={setHabDetail}
        />
      )}
      {screen === "misReservas" && authed && (
        <ScreenMisReservas />
      )}
      {screen === "actualizar" && authed && (
        <div className="page">
          <h2 className="page-title">Actualizar Datos</h2>
          <div className="subtabs">
            <div className="subtab active">Mis Datos</div>
          </div>
          <div className="section" style={{ padding: 30, color: "#5A5A5A" }}>
            <p>Aquí el usuario podrá actualizar su información personal: dirección, teléfono, email y preguntas de seguridad.</p>
            <p style={{ marginTop: 14 }}>
              <em>(Pantalla equivalente a "Registro Nuevo Usuario" pero con los datos cargados y la posibilidad de editarlos.)</em>
            </p>
          </div>
        </div>
      )}

      <ModalDetalleHabitacion habitacion={habDetail} onClose={() => setHabDetail(null)} />
      <ModalConfirmacion open={confirmOpen} onClose={() => setConfirmOpen(false)} onConfirm={confirmReserva} data={reservaData} />

      <Footer />
    </div>
  );
}

ReactDOM.createRoot(document.getElementById("root")).render(<App />);
