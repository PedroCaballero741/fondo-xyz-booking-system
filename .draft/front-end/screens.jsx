// FODUN Sistema de Reservas — screens
// Pantallas según el anexo prueba técnica mayo 2026

const { useState, useEffect, useMemo } = React;

// ============ Datos mock ============
const SEDES = [
  {
    id: 1,
    nombre: "Sede Recreativa Villeta",
    tipo: "Sede Recreativa",
    ubicacion: "Villeta",
    descripcion: "Esta Sede recreativa se encuentra ubicada en el barrio San Jorge a poca distancia de la plaza central de Villeta en la Provincia del Gualivá, Cundinamarca",
    descripcionLarga: [
      "Esta Sede recreativa se encuentra ubicada en el barrio San Jorge a poca distancia de la plaza central de Villeta en la Provincia del Gualivá, Cundinamarca, distante de Bogotá 90 kilómetros, aproximadamente hora y media por la autopista Bogotá - Medellín.",
      "La sede recreativa tiene un área aproximada de 1 fanegada, con amplias zonas verdes.",
      "**Servicios de la sede**",
      "Sala de estar y Televisión, sala de conferencias con capacidad para 20 personas, zona de juegos: billar, tenis de mesa, futbolín y juegos de mesa.",
      "Área para comedores, 4 cocinetas equipadas, baños de emergencia, vestieres y lockers para visita día, tienda, sauna, jacuzzi, piscina, cancha de microfutbol y amplias zonas verdes.",
      "**Alojamientos**",
      "Ocho habitaciones cada una con una alcoba que tiene una cama doble y un camarote, baño, nevera, televisor y terraza cubierta.",
      "**Capacidad total: hasta 32 personas**"
    ],
    img: "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=400&q=70",
    galeria: [
      "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&q=70",
      "https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?w=400&q=70",
      "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400&q=70",
      "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=400&q=70",
      "https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=400&q=70",
    ],
    habitaciones: Array.from({ length: 8 }, (_, i) => ({
      id: i + 1,
      numero: i + 1,
      capacidad: 4,
      tarifaOrdinaria: 100000,
      tarifaEspecial: 120000,
      disponible: i !== 1 && i !== 3,
    })),
  },
  {
    id: 2,
    nombre: "Sede Recreativa el Placer",
    tipo: "Sede Recreativa",
    ubicacion: "Fusagasugá",
    descripcion: "Esta Sede recreativa se encuentra ubicada en la vereda El Placer del municipio de Fusagasugá, a unos 10 minutos del casco urbano",
    descripcionLarga: [
      "Esta Sede recreativa se encuentra ubicada en la vereda El Placer del municipio de Fusagasugá, a unos 10 minutos del casco urbano.",
      "Zonas verdes, piscina, salón social y áreas de descanso ideal para familias.",
    ],
    img: "https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=400&q=70",
    galeria: [
      "https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800&q=70",
      "https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?w=400&q=70",
    ],
    habitaciones: Array.from({ length: 6 }, (_, i) => ({
      id: i + 1,
      numero: i + 1,
      capacidad: 4,
      tarifaOrdinaria: 90000,
      tarifaEspecial: 110000,
      disponible: i !== 2,
    })),
  },
  {
    id: 3,
    nombre: "Edificio Suramericana",
    tipo: "Apartamento",
    ubicacion: "Antioquia",
    descripcion: "Ubicado en la Calle 49 B Nº 64B-15 en el edificio Suramericana Nº 6 Apartamento 1204. Cerca del campus de la Universidad Nacional de Colombia",
    descripcionLarga: [
      "Ubicado en la Calle 49 B Nº 64B-15 en el edificio Suramericana Nº 6 Apartamento 1204.",
      "Cerca del campus de la Universidad Nacional de Colombia, sede Medellín.",
    ],
    img: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400&q=70",
    galeria: ["https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=70"],
    habitaciones: Array.from({ length: 3 }, (_, i) => ({
      id: i + 1,
      numero: i + 1,
      capacidad: 3,
      tarifaOrdinaria: 80000,
      tarifaEspecial: 95000,
      disponible: true,
    })),
  },
  {
    id: 4,
    nombre: "Edificio Reina 1",
    tipo: "Apartamento",
    ubicacion: "Santa Marta",
    descripcion: "Ubicados en el edificio REINA 1 de la Carrera 3 número 7 — 85 centro urbano y turístico El Rodadero y a tres cuadras de la playa.",
    descripcionLarga: [
      "Ubicados en el edificio REINA 1 de la Carrera 3 número 7 — 85 centro urbano y turístico El Rodadero y a tres cuadras de la playa.",
      "Apartamento de 3 habitaciones, cocina equipada y vista al mar.",
    ],
    img: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=70",
    galeria: ["https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=70"],
    habitaciones: Array.from({ length: 3 }, (_, i) => ({
      id: i + 1,
      numero: i + 1,
      capacidad: 4,
      tarifaOrdinaria: 110000,
      tarifaEspecial: 135000,
      disponible: true,
    })),
  },
];

const MIS_RESERVAS = [
  { lugar: "Sede Recreativa Villeta", fechaReserva: "08-01-2014", fechaLlegada: "08-01-2014", fechaSalida: "08-01-2014", personas: 4, habitaciones: 1, valor: 800000, comprobante: "pendiente" },
  { lugar: "Sede Recreativa el Placer", fechaReserva: "08-01-2013", fechaLlegada: "08-01-2013", fechaSalida: "08-01-2013", personas: 6, habitaciones: 2, valor: 700000, comprobante: "subido" },
  { lugar: "Edificio Suramericana", fechaReserva: "08-01-2012", fechaLlegada: "08-01-2012", fechaSalida: "08-01-2012", personas: 3, habitaciones: 1, valor: 600000, comprobante: "subido" },
  { lugar: "Edificio Reina 1", fechaReserva: "08-01-2011", fechaLlegada: "08-01-2011", fechaSalida: "08-01-2011", personas: 5, habitaciones: 2, valor: 500000, comprobante: "subido" },
];

const fmtCOP = (n) => "$" + n.toLocaleString("es-CO");

// ============ Logo SVG ============
function LogoMark({ size = 56, color = "#FFF" }) {
  return (
    <svg viewBox="0 0 100 100" width={size} height={size}>
      <path d="M22 22 L78 78 M78 22 L22 78" stroke={color} strokeWidth="11" strokeLinecap="round" />
    </svg>
  );
}

function BrandLogo() {
  return (
    <div className="brand">
      <div className="brand-logo"><LogoMark /></div>
      <div className="brand-name">FODUN</div>
    </div>
  );
}

// ============ Header + Nav ============
function Header() {
  return (
    <header className="header">
      <BrandLogo />
      <div className="header-banner">
        <h1>SISTEMA DE RESERVAS</h1>
        <h2>Sedes Recreativas y Apartamentos</h2>
      </div>
    </header>
  );
}

function Nav({ screen, setScreen, authed, user, onLogout }) {
  const publicTabs = [
    { id: "sedes", label: "Sedes Recreativas y Apartamentos" },
    { id: "login", label: "Ingreso y Registro" },
  ];
  const privateTabs = [
    { id: "sedes", label: "Sedes Recreativas y Apartamentos" },
    { id: "misReservas", label: "Mis Reservas" },
    { id: "actualizar", label: "Actualizar Datos" },
    { id: "cerrar", label: "Cerrar Cesión" },
  ];
  const tabs = authed ? privateTabs : publicTabs;

  const handleClick = (id) => {
    if (id === "cerrar") { onLogout(); return; }
    setScreen(id);
  };

  return (
    <nav className="nav">
      <div className="nav-tabs">
        {tabs.map(t => (
          <button
            key={t.id}
            className={"nav-tab " + (screen === t.id ? "active" : "")}
            onClick={() => handleClick(t.id)}
          >
            {t.label}
          </button>
        ))}
      </div>
      {authed && (
        <div className="nav-user">
          <span className="nav-user-icon">👤</span>
          <span>Bienvenido, {user}</span>
        </div>
      )}
    </nav>
  );
}

function Footer() {
  return (
    <footer className="footer">
      FODUN - Fondo de Docentes Universidad Nacional - Derechos Reservados © 2014 - Desarrollado por MarketingItSolutions S.A.S
    </footer>
  );
}

// ============ Spinner input ============
function Spinner({ value, onChange, min = 0, max = 99 }) {
  return (
    <div className="spinner-input">
      <input value={value} onChange={(e) => {
        const v = parseInt(e.target.value || "0");
        if (!isNaN(v) && v >= min && v <= max) onChange(v);
      }} />
      <div className="arrows">
        <button onClick={() => onChange(Math.min(max, value + 1))}>▲</button>
        <button onClick={() => onChange(Math.max(min, value - 1))}>▼</button>
      </div>
    </div>
  );
}

function Checkbox({ checked, onChange }) {
  return <span className={"checkbox " + (checked ? "checked" : "")} onClick={() => onChange(!checked)} />;
}

function Radio({ checked, onChange }) {
  return <span className={"radio " + (checked ? "checked" : "")} onClick={() => onChange(true)} />;
}

// ============================================================
// Screen 1 — Sedes Recreativas y Apartamentos (lista)
// ============================================================
function ScreenSedes({ onSelect, authed }) {
  const [tab, setTab] = useState("sedes");

  return (
    <div className="page">
      <h2 className="page-title">Sedes Recreativas y Apartamentos</h2>

      <div className="subtabs">
        <div className={"subtab " + (tab === "sedes" ? "active" : "")} onClick={() => setTab("sedes")}>
          Sedes Recreativas y Apartamentos
        </div>
        <div className={"subtab " + (tab === "fechas" ? "active" : "")} onClick={() => setTab("fechas")}>
          Seleccione sus Fechas
        </div>
      </div>

      <div className="section">
        <div className="list-header">
          <div>&nbsp;</div>
          <div>Nombre</div>
          <div>Descripción</div>
          <div>Tipo</div>
          <div>Ubicación</div>
          <div>Seleccionar</div>
        </div>
        {SEDES.map(s => (
          <div className="sede-row" key={s.id}>
            <div className="sede-thumb" style={{ backgroundImage: `url(${s.img})` }} />
            <div className="name">{s.nombre}</div>
            <div className="desc">{s.descripcion}</div>
            <div className="tipo">{s.tipo}</div>
            <div className="loc">{s.ubicacion}</div>
            <div className="pick">
              <button className="btn btn-primary" onClick={() => onSelect(s)}>Seleccionar</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ============================================================
// Screen 2 — Detalle de Sede + Selección Fechas + Habitaciones
// ============================================================
function ScreenDetalle({ sede, onBack, onReservar, onVerDetalle }) {
  const [llegada, setLlegada] = useState("");
  const [salida, setSalida] = useState("");
  const [noches, setNoches] = useState(0);
  const [personas, setPersonas] = useState(0);
  const [lavanderia, setLavanderia] = useState(false);
  const [habitacionesSel, setHabitacionesSel] = useState({});
  const [galleryIdx, setGalleryIdx] = useState(0);

  // calcular noches automáticamente
  useEffect(() => {
    if (llegada && salida) {
      const a = new Date(llegada);
      const b = new Date(salida);
      const diff = Math.max(0, Math.round((b - a) / 86400000));
      setNoches(diff);
    }
  }, [llegada, salida]);

  const habs = sede.habitaciones || [];
  const reservadas = habs.filter(h => habitacionesSel[h.id]);
  const numHabs = reservadas.length;

  // mock: 2 días especiales si hay noches
  const diasOrd = Math.max(0, noches - (noches > 2 ? 1 : 0));
  const diasEsp = noches - diasOrd;

  const lavanderiaTotal = lavanderia ? 15000 * numHabs * noches : 0;
  const tarifaTotal = reservadas.reduce((sum, h) => sum + (h.tarifaOrdinaria * diasOrd) + (h.tarifaEspecial * diasEsp), 0);
  const valorTotal = tarifaTotal + lavanderiaTotal;

  return (
    <div className="page">
      <h2 className="page-title">Sedes Recreativas y Apartamentos</h2>

      <div className="subtabs">
        <div className="subtab" onClick={onBack}>Sedes Recreativas y Apartamentos</div>
        <div className="subtab active">Seleccione sus Fechas</div>
      </div>

      <div className="section">
        <div className="detail-grid">
          {/* Left form */}
          <div className="detail-left">
            <h3>Mis Fechas</h3>
            <div className="form-row">
              <label>Fecha de Llegada:</label>
              <input type="date" className="input input-md" value={llegada} onChange={e => setLlegada(e.target.value)} />
              <span className="cal-icon">📅</span>
            </div>
            <div className="form-row">
              <label>Fecha de Salida:</label>
              <input type="date" className="input input-md" value={salida} onChange={e => setSalida(e.target.value)} />
              <span className="cal-icon">📅</span>
            </div>
            <div className="form-row">
              <label>Noches:</label>
              <Spinner value={noches} onChange={setNoches} />
            </div>
            <div className="form-row">
              <label>Personas:</label>
              <Spinner value={personas} onChange={setPersonas} />
            </div>
            <div className="form-row" style={{ marginTop: 16 }}>
              <label style={{ width: 110, lineHeight: 1.2 }}>Servicio de<br/>Lavandería:</label>
              <Checkbox checked={lavanderia} onChange={setLavanderia} />
            </div>

            <div className="divider" />

            <h3>Total Reserva</h3>
            <div className="form-row">
              <label>Habitaciones:</label>
              <input className="input input-sm" value={numHabs} readOnly />
            </div>
            <div className="form-row">
              <label>Días Ordinarios:</label>
              <input className="input input-sm" value={diasOrd} readOnly />
              <input className="input input-md" value={diasOrd ? fmtCOP(reservadas.reduce((a,h)=>a+h.tarifaOrdinaria*diasOrd,0)) : ""} readOnly />
            </div>
            <div className="form-row">
              <label>Días Expeciales:</label>
              <input className="input input-sm" value={diasEsp} readOnly />
              <input className="input input-md" value={diasEsp ? fmtCOP(reservadas.reduce((a,h)=>a+h.tarifaEspecial*diasEsp,0)) : ""} readOnly />
            </div>
            <div className="form-row">
              <label>Lavandería:</label>
              <input className="input input-md" value={lavanderia ? fmtCOP(lavanderiaTotal) : ""} readOnly />
            </div>
            <div className="total-line">
              <div className="lbl">Valor Total:</div>
              <div className="val">{fmtCOP(valorTotal || 0).replace("$", "$").replace(",", ".") || "$000.000"}</div>
            </div>
            <div style={{ marginLeft: 120 }}>
              <button className="btn btn-primary btn-lg" onClick={onReservar} disabled={numHabs === 0 || noches === 0}>
                Reservar
              </button>
            </div>
          </div>

          {/* Right gallery + description */}
          <div>
            <h3 style={{ color: "var(--fodun-red-text)", margin: "0 0 10px", fontSize: 16, fontWeight: 700 }}>
              {sede.nombre}
            </h3>
            <div className="detail-content">
              <div className="gallery">
                <div className="gallery-main" style={{ backgroundImage: `url(${sede.galeria[galleryIdx] || sede.img})` }} />
                <div className="gallery-thumbs">
                  {sede.galeria.slice(0, 4).map((g, i) => (
                    <div key={i}
                      className={i === galleryIdx ? "active" : ""}
                      style={{ backgroundImage: `url(${g})` }}
                      onClick={() => setGalleryIdx(i)} />
                  ))}
                </div>
                <div className="download-route">
                  <svg viewBox="0 0 60 60" fill="none">
                    <rect x="6" y="14" width="48" height="34" rx="2" fill="#FFF" stroke="#A8202F" strokeWidth="1.5"/>
                    <path d="M6 14 L30 32 L54 14" fill="none" stroke="#A8202F" strokeWidth="1.5"/>
                    <circle cx="30" cy="30" r="6" fill="none" stroke="#A8202F" strokeWidth="1.5"/>
                    <path d="M30 24 V36 M24 30 H36" stroke="#A8202F" strokeWidth="1.5"/>
                  </svg>
                  <span>Descargar<br/>ruta de llegada</span>
                </div>
              </div>
              <div className="detail-text">
                {sede.descripcionLarga.map((p, i) => {
                  if (p.startsWith("**") && p.endsWith("**")) {
                    return <p key={i}><strong>{p.replace(/\*\*/g, "")}</strong></p>;
                  }
                  return <p key={i}>{p}</p>;
                })}
              </div>
            </div>
          </div>
        </div>

        <h3 className="habitaciones-title">Habitaciones / Alojamientos</h3>
        <table className="table">
          <thead>
            <tr>
              <th style={{ width: 80 }}>Detalles</th>
              <th>Habitación /<br/>Alojamiento</th>
              <th>Capacidad</th>
              <th>Tarifa día<br/>Ordinario</th>
              <th>Tarifa día<br/>Expecial</th>
              <th>Disponibilidad<br/>Fecha Seleccionada</th>
              <th>Ver Calendario<br/>Disponibilidad</th>
              <th>Reservar</th>
            </tr>
          </thead>
          <tbody>
            {habs.map(h => (
              <tr key={h.id} className={!h.disponible ? "disabled" : ""}>
                <td>
                  <button className="search-icon" onClick={() => onVerDetalle(h)} title="Ver detalles">
                    <svg width="18" height="18" viewBox="0 0 20 20" fill="none">
                      <circle cx="8" cy="8" r="5.5" stroke="currentColor" strokeWidth="1.5"/>
                      <path d="M12 12 L17 17" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
                    </svg>
                  </button>
                </td>
                <td>{h.numero}</td>
                <td>{h.capacidad}</td>
                <td>{fmtCOP(h.tarifaOrdinaria)}</td>
                <td>{fmtCOP(h.tarifaEspecial)}</td>
                <td>{h.disponible ? <span className="check-mark">✓</span> : <span className="x-mark">✗</span>}</td>
                <td><span className="cal-icon">📅</span></td>
                <td>
                  {h.disponible && (
                    <Checkbox
                      checked={!!habitacionesSel[h.id]}
                      onChange={(v) => setHabitacionesSel({ ...habitacionesSel, [h.id]: v })}
                    />
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ============================================================
// Modal 1 — Detalle Habitación
// ============================================================
function ModalDetalleHabitacion({ habitacion, onClose }) {
  if (!habitacion) return null;
  const amenities = [
    "Cama doble", "Camarote", "Baño", "Nevera", "Televisor", "Terraza Cubierta"
  ];
  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <div className="modal-header">
          Detalle Habitación / Alojamiento
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>
        <div className="modal-body">
          <p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.</p>
          <div className="modal-cols">
            <div>
              {amenities.map(a => (
                <div className="item" key={a}>
                  <span className="check">✓</span>
                  <span className="lbl">{a}</span>
                </div>
              ))}
            </div>
            <div>
              <div className="item"><span className="check">✓</span><span className="lbl">Habitación /Alojamiento:</span><span className="val">{habitacion.numero}</span></div>
              <div className="item"><span className="check">✓</span><span className="lbl">Capacidad:</span><span className="val">{habitacion.capacidad}</span></div>
              <div className="item"><span className="check">✓</span><span className="lbl">Tarifa día Ordinario:</span><span className="val">{fmtCOP(habitacion.tarifaOrdinaria)}</span></div>
              <div className="item"><span className="check">✓</span><span className="lbl">Tarifa día Expecial:</span><span className="val">{fmtCOP(habitacion.tarifaEspecial)}</span></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ============================================================
// Modal 2 — Confirmación de Reserva
// ============================================================
function ModalConfirmacion({ open, onClose, onConfirm, data }) {
  if (!open) return null;
  return (
    <div className="modal-backdrop" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>
        <div className="modal-header">
          Confirmación Reserva
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>
        <div className="modal-body">
          <p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.</p>
          <div className="modal-cols">
            <div>
              <h4 style={{ color: "var(--fodun-red)", margin: "0 0 10px", borderBottom: "1px solid #CFCFCF", paddingBottom: 4 }}>Mis Fechas</h4>
              <div className="form-row" style={{ marginBottom: 6 }}>
                <label style={{ width: 110 }}>Fecha de Llegada:</label>
                <input className="input input-md" value={data.llegada || ""} readOnly />
              </div>
              <div className="form-row" style={{ marginBottom: 6 }}>
                <label style={{ width: 110 }}>Fecha de Salida:</label>
                <input className="input input-md" value={data.salida || ""} readOnly />
              </div>
              <div className="form-row" style={{ marginBottom: 6 }}>
                <label style={{ width: 110 }}>Noches:</label>
                <input className="input input-sm" value={data.noches || 0} readOnly />
              </div>
              <div className="form-row" style={{ marginBottom: 6 }}>
                <label style={{ width: 110 }}>Personas:</label>
                <input className="input input-sm" value={data.personas || 0} readOnly />
              </div>
              <div className="form-row" style={{ marginBottom: 6 }}>
                <label style={{ width: 110, lineHeight: 1.2 }}>Servicio de<br/>Lavandería:</label>
                <Checkbox checked={data.lavanderia} onChange={() => {}} />
              </div>
            </div>
            <div>
              <h4 style={{ color: "var(--fodun-red)", margin: "0 0 10px", borderBottom: "1px solid #CFCFCF", paddingBottom: 4 }}>Total Reserva</h4>
              <div className="form-row" style={{ marginBottom: 6 }}>
                <label style={{ width: 110 }}>Habitaciones:</label>
                <input className="input input-sm" value={data.numHabs || 0} readOnly />
              </div>
              <div className="form-row" style={{ marginBottom: 6 }}>
                <label style={{ width: 110 }}>Días Ordinarios:</label>
                <input className="input input-sm" value={data.diasOrd || 0} readOnly />
                <input className="input input-md" value={fmtCOP(data.tOrd || 0)} readOnly />
              </div>
              <div className="form-row" style={{ marginBottom: 6 }}>
                <label style={{ width: 110 }}>Días Expeciales:</label>
                <input className="input input-sm" value={data.diasEsp || 0} readOnly />
                <input className="input input-md" value={fmtCOP(data.tEsp || 0)} readOnly />
              </div>
              <div className="form-row" style={{ marginBottom: 6 }}>
                <label style={{ width: 110 }}>Lavandería:</label>
                <input className="input input-md" value={fmtCOP(data.tLav || 0)} readOnly />
              </div>
              <div className="total-line" style={{ marginTop: 10 }}>
                <div className="lbl" style={{ width: 110 }}>Valor Total:</div>
                <div className="val">{fmtCOP(data.valorTotal || 0)}</div>
              </div>
            </div>
          </div>
          <div className="modal-actions">
            <button className="btn btn-primary btn-lg" onClick={onConfirm}>Confirmar</button>
            <button className="btn btn-primary btn-lg" onClick={onClose}>Cancelar</button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ============================================================
// Screen 5 — Mis Reservas
// ============================================================
function ScreenMisReservas() {
  return (
    <div className="page">
      <h2 className="page-title">Mis Reservas</h2>
      <div className="subtabs">
        <div className="subtab active">Mis Reservas</div>
      </div>
      <div className="section">
        <table className="table">
          <thead>
            <tr>
              <th style={{ width: 80 }}>Ampliar</th>
              <th>Lugar</th>
              <th>Fecha Reserva</th>
              <th>Fecha Llegada</th>
              <th>Fecha Salida</th>
              <th>No. Personas</th>
              <th>No. Habitaciones</th>
              <th>Valor Total</th>
              <th>Comprobante<br/>de Pago</th>
            </tr>
          </thead>
          <tbody>
            {MIS_RESERVAS.map((r, i) => (
              <tr key={i}>
                <td>
                  <button className="search-icon">
                    <svg width="18" height="18" viewBox="0 0 20 20" fill="none">
                      <circle cx="8" cy="8" r="5.5" stroke="currentColor" strokeWidth="1.5"/>
                      <path d="M12 12 L17 17" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
                    </svg>
                  </button>
                </td>
                <td>{r.lugar}</td>
                <td>{r.fechaReserva}</td>
                <td>{r.fechaLlegada}</td>
                <td>{r.fechaSalida}</td>
                <td>{r.personas}</td>
                <td>{r.habitaciones}</td>
                <td>{fmtCOP(r.valor)}</td>
                <td>
                  {r.comprobante === "pendiente" ? (
                    <button className="btn btn-primary btn-sm">Enviar</button>
                  ) : (
                    <span style={{ display: "inline-flex", alignItems: "center" }}>
                      <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                        <rect x="5" y="3" width="14" height="18" rx="1" fill="#FFF" stroke="#2A6FBA" strokeWidth="1.5"/>
                        <line x1="8" y1="8" x2="16" y2="8" stroke="#2A6FBA" strokeWidth="1.2"/>
                        <line x1="8" y1="11" x2="16" y2="11" stroke="#2A6FBA" strokeWidth="1.2"/>
                        <line x1="8" y1="14" x2="13" y2="14" stroke="#2A6FBA" strokeWidth="1.2"/>
                      </svg>
                    </span>
                  )}
                </td>
              </tr>
            ))}
            {Array.from({ length: 4 }).map((_, i) => (
              <tr key={"empty" + i} className="empty-row">
                <td colSpan={9}>&nbsp;</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ============================================================
// Screen 6 — Login con teclado dinámico
// ============================================================
function ScreenLogin({ onLogin, onGoRegister }) {
  const [doc, setDoc] = useState("");
  const [clave, setClave] = useState("");
  const [keypadOrder, setKeypadOrder] = useState(() => shuffleKeypad());

  function shuffleKeypad() {
    const nums = [0,1,2,3,4,5,6,7,8,9];
    for (let i = nums.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [nums[i], nums[j]] = [nums[j], nums[i]];
    }
    return nums;
  }

  const pressNum = (n) => {
    if (clave.length < 4) setClave(clave + n);
  };
  const clearClave = () => setClave("");
  const submitLogin = () => {
    if (!doc.trim() || clave.length < 4) {
      alert("Ingrese su número de documento y los 4 dígitos de su clave.");
      return;
    }
    onLogin(doc.trim());
  };

  // Re-shuffle on mount only (cada carga distinta)

  return (
    <div className="page" style={{ padding: 0 }}>
      <div className="page" style={{ padding: "22px 36px 0" }}>
        <div className="subtabs">
          <div className="subtab">Sedes Recreativas y Apartamentos</div>
          <div className="subtab active">Ingreso y Registro</div>
        </div>
      </div>

      <div className="section" style={{ borderTop: "none" }}>
        <div className="login-wrap">
          <div className="login-hero">
            <div className="login-hero-logo">
              <LogoMark size={48} color="#A8202F" />
              <div className="txt">
                FODUN
                <small>FONDO DE DOCENTES<br/>UNIVERSIDAD NACIONAL DE COLOMBIA</small>
              </div>
            </div>
          </div>

          <div>
            <div className="login-card-title">Ingreso Sistema de Reservas</div>
            <div className="login-msg">
              Digite su Clave a través del teclado dinámico que<br/>se encuentra en la pantalla.
            </div>

            <div style={{ display: "flex", gap: 14, alignItems: "flex-start" }}>
              <div className="login-form">
                <label>Nro Documento:</label>
                <input className="input input-md" value={doc} onChange={e => setDoc(e.target.value)} />
                <label>Clave:</label>
                <input className="input input-md" type="password" value={clave} readOnly />
                <div className="login-actions" style={{ gridColumn: "1 / -1" }}>
                  <button className="btn btn-primary" onClick={submitLogin}>Aceptar</button>
                  <a href="#" className="forgot" onClick={e => e.preventDefault()}>¿Olvido su clave?</a>
                </div>
              </div>

              <div>
                <div className="keypad">
                  {keypadOrder.slice(0, 3).map(n => (
                    <button key={n} onClick={() => pressNum(n)}>{n}</button>
                  ))}
                  {keypadOrder.slice(3, 6).map(n => (
                    <button key={n} onClick={() => pressNum(n)}>{n}</button>
                  ))}
                  {keypadOrder.slice(6, 9).map(n => (
                    <button key={n} onClick={() => pressNum(n)}>{n}</button>
                  ))}
                  <button onClick={() => pressNum(keypadOrder[9])}>{keypadOrder[9]}</button>
                  <button className="keypad-clear" onClick={clearClave}>Limpiar</button>
                  <button className="keypad-clear" onClick={() => setKeypadOrder(shuffleKeypad())}>↻</button>
                </div>
                <div className="contraste">
                  <span className="contraste-label">Contraste</span>
                  <div className="contraste-row">
                    <button></button><button></button><button></button>
                  </div>
                </div>
              </div>
            </div>

            <div className="login-bottom" onClick={onGoRegister}>
              <div className="txt">
                <h3>¿Usuario Nuevo?</h3>
                <p>REGÍSTRESE AQUÍ</p>
              </div>
              <div className="mouse">🖱️</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ============================================================
// Screen 7 — Registro Nuevo Usuario
// ============================================================
function ScreenRegistro({ onCancel, onRegistered }) {
  const [form, setForm] = useState({
    doc: "", nombre: "", fechaNac: "", celular: "", email: "",
    depto: "", municipio: "", barrio: "", direccion: "", telefono: "",
    pregunta: "", respuesta: "", autorizaEmail: "si", autorizaCel: "si",
    clave: "", claveConf: ""
  });
  const set = (k) => (e) => setForm({ ...form, [k]: e.target.value });

  const submit = () => {
    if (!form.doc || !form.nombre || !form.email) {
      alert("Complete los campos obligatorios (marcados con *)");
      return;
    }
    if (form.clave !== form.claveConf) {
      alert("Las claves no coinciden.");
      return;
    }
    if (form.clave.length !== 4) {
      alert("La clave debe contener 4 dígitos.");
      return;
    }
    onRegistered(form.nombre);
  };

  return (
    <div className="page">
      <h2 className="page-title">Registro Nuevo Usuario</h2>
      <div className="subtabs">
        <div className="subtab active">Registro Usuario</div>
      </div>
      <div className="section">
        <div className="register">
          {/* Col 1 */}
          <div>
            <div className="field">
              <label>Nro Documento: <span className="req">*</span></label>
              <input className="input" value={form.doc} onChange={set("doc")} />
            </div>
            <div className="field">
              <label>Nombre Completo: <span className="req">*</span></label>
              <input className="input" value={form.nombre} onChange={set("nombre")} />
            </div>
            <div className="field">
              <label>Fecha de Nacimiento: <span className="req">*</span></label>
              <input className="input" type="date" value={form.fechaNac} onChange={set("fechaNac")} />
            </div>
            <div className="field">
              <label>Celular:</label>
              <input className="input" value={form.celular} onChange={set("celular")} />
            </div>
            <div className="field">
              <label>Direccion Email: <span className="req">*</span></label>
              <input className="input" type="email" value={form.email} onChange={set("email")} />
            </div>
            <div className="field">
              <label>Departamento: <span className="req">*</span></label>
              <select className="select" value={form.depto} onChange={set("depto")}>
                <option value="">SELECCIONE ..</option>
                <option>Antioquia</option>
                <option>Cundinamarca</option>
                <option>Magdalena</option>
                <option>Atlántico</option>
                <option>Valle del Cauca</option>
              </select>
            </div>
            <div className="field">
              <label>Municipio: <span className="req">*</span></label>
              <select className="select" value={form.municipio} onChange={set("municipio")}>
                <option value="">SELECCIONE ..</option>
                <option>Medellín</option>
                <option>Bogotá</option>
                <option>Santa Marta</option>
                <option>Fusagasugá</option>
                <option>Villeta</option>
              </select>
            </div>
            <div className="field">
              <label>Barrio: <span className="req">*</span></label>
              <input className="input" value={form.barrio} onChange={set("barrio")} />
            </div>
            <div className="field">
              <label>Direccion Residencia: <span className="req">*</span></label>
              <input className="input" value={form.direccion} onChange={set("direccion")} />
            </div>
            <div className="field">
              <label>Telefono Residencia: <span className="req">*</span></label>
              <input className="input" value={form.telefono} onChange={set("telefono")} />
            </div>
          </div>

          {/* Col 2 */}
          <div>
            <div className="field">
              <label>Pregunta Secreta: <span className="req">*</span></label>
              <select className="select" value={form.pregunta} onChange={set("pregunta")}>
                <option value="">SELECCIONE UNA PREGUNTA..</option>
                <option>¿Nombre de su primera mascota?</option>
                <option>¿Ciudad donde nació?</option>
                <option>¿Apellido materno de su madre?</option>
                <option>¿Nombre de su mejor amigo de la infancia?</option>
              </select>
            </div>
            <div className="field">
              <label>Respuesta Secreta: <span className="req">*</span></label>
              <input className="input" value={form.respuesta} onChange={set("respuesta")} />
              <div className="help">Esta Respuesta Se Utilizara para la Recuperación de la Clave</div>
            </div>
            <div className="field">
              <label>¿Autoriza el Envio de informacion al Correo?:</label>
              <div style={{ display: "flex", gap: 28, marginTop: 6 }}>
                <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
                  <Radio checked={form.autorizaEmail === "si"} onChange={() => setForm({ ...form, autorizaEmail: "si" })} /> Si
                </span>
                <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
                  <Radio checked={form.autorizaEmail === "no"} onChange={() => setForm({ ...form, autorizaEmail: "no" })} /> No
                </span>
              </div>
            </div>
            <div className="field">
              <label>¿Autoriza el Envio de informacion al Celular?:</label>
              <div style={{ display: "flex", gap: 28, marginTop: 6 }}>
                <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
                  <Radio checked={form.autorizaCel === "si"} onChange={() => setForm({ ...form, autorizaCel: "si" })} /> Si
                </span>
                <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
                  <Radio checked={form.autorizaCel === "no"} onChange={() => setForm({ ...form, autorizaCel: "no" })} /> No
                </span>
              </div>
            </div>
            <div className="field">
              <label>Clave: <span className="req">*</span></label>
              <input className="input" type="password" maxLength={4} value={form.clave} onChange={set("clave")} style={{ width: 130 }} />
              <div className="help">La Clave solo debe Contener 4 Numeros</div>
            </div>
            <div className="field">
              <label>Confirmar Clave: <span className="req">*</span></label>
              <input className="input" type="password" maxLength={4} value={form.claveConf} onChange={set("claveConf")} style={{ width: 130 }} />
            </div>
          </div>

          <div className="register-actions">
            <button className="btn btn-primary" onClick={submit}>📨 Enviar</button>
            <button className="btn btn-secondary" onClick={onCancel}>✕ Cancelar</button>
          </div>
        </div>
      </div>
    </div>
  );
}

// expose to global
Object.assign(window, {
  ScreenSedes, ScreenDetalle, ScreenMisReservas, ScreenLogin, ScreenRegistro,
  ModalDetalleHabitacion, ModalConfirmacion,
  Header, Nav, Footer, BrandLogo, SEDES, fmtCOP
});
