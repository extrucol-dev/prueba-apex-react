import { useState, useEffect, useCallback } from 'react'
import { clientesApi } from '../api/clientesApi'
import ClienteModal from './ClienteModal'

export default function ClientesCrud() {
  const [clientes, setClientes] = useState([])
  const [loading, setLoading]   = useState(true)
  const [error, setError]       = useState(null)
  const [modal, setModal]       = useState({ open: false, data: null })
  const [deleting, setDeleting] = useState(null)

  const load = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      setClientes(await clientesApi.list())
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { load() }, [load])

  const openCreate = () => setModal({ open: true, data: null })
  const openEdit   = (c)  => setModal({ open: true, data: c })
  const closeModal = ()   => setModal({ open: false, data: null })

  const handleSave = async (formData) => {
    if (formData.id) {
      await clientesApi.update(formData)
    } else {
      await clientesApi.create(formData)
    }
    closeModal()
    load()
  }

  const handleDelete = async (id) => {
    if (!window.confirm('¿Eliminar este cliente? Esta acción no se puede deshacer.')) return
    setDeleting(id)
    try {
      await clientesApi.delete(id)
      load()
    } catch (e) {
      setError(e.message)
    } finally {
      setDeleting(null)
    }
  }

  return (
    <div className="crud">

      <div className="crud-header">
        <div>
          <h1>Clientes</h1>
          <p className="muted" style={{ marginTop: 4 }}>
            {loading ? 'Cargando...' : `${clientes.length} registros`}
          </p>
        </div>
        <button className="btn" onClick={openCreate}>+ Nuevo Cliente</button>
      </div>

      {error && <div className="alert">{error}</div>}

      <div className="chart-card">
        {loading ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {[...Array(5)].map((_, i) => (
              <div key={i} className="skeleton skeleton-row" />
            ))}
          </div>
        ) : clientes.length === 0 ? (
          <p className="muted" style={{ textAlign: 'center', padding: '32px 0' }}>
            No hay clientes. Crea el primero.
          </p>
        ) : (
          <div className="table-wrap">
            <table className="ventas-table">
              <thead>
                <tr>
                  <th className="num">ID</th>
                  <th>Nombre</th>
                  <th>Email</th>
                  <th>Ciudad</th>
                  <th>País</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                {clientes.map(c => (
                  <tr key={c.id}>
                    <td className="num">{c.id}</td>
                    <td>{c.nombre}</td>
                    <td style={{ color: 'var(--text-mute)' }}>{c.email || '—'}</td>
                    <td>{c.ciudad || '—'}</td>
                    <td>
                      <span className="badge badge-amber">{c.pais}</span>
                    </td>
                    <td>
                      <button className="btn-edit" onClick={() => openEdit(c)}>
                        Editar
                      </button>
                      <button
                        className="btn-del"
                        onClick={() => handleDelete(c.id)}
                        disabled={deleting === c.id}
                      >
                        {deleting === c.id ? '...' : 'Eliminar'}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {modal.open && (
        <ClienteModal
          data={modal.data}
          onSave={handleSave}
          onClose={closeModal}
        />
      )}
    </div>
  )
}
