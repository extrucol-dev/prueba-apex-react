import { useState, useEffect } from 'react'

const EMPTY = { nombre: '', email: '', ciudad: '', pais: 'MX' }

export default function ClienteModal({ data, onSave, onClose }) {
  const [form, setForm]     = useState(EMPTY)
  const [saving, setSaving] = useState(false)
  const [error, setError]   = useState(null)

  useEffect(() => {
    setForm(data ? { ...data } : EMPTY)
    setError(null)
  }, [data])

  const set = (k) => (e) => setForm(f => ({ ...f, [k]: e.target.value }))

  const submit = async (e) => {
    e.preventDefault()
    setSaving(true)
    setError(null)
    try {
      await onSave(form)
    } catch (err) {
      setError(err.message)
      setSaving(false)
    }
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e => e.stopPropagation()}>

        <div className="modal-head">
          <h2>{data ? 'Editar Cliente' : 'Nuevo Cliente'}</h2>
          <button type="button" className="modal-close" onClick={onClose}>✕</button>
        </div>

        <form onSubmit={submit}>
          <div className="modal-body">
            {error && <div className="alert">{error}</div>}

            <div className="form-group">
              <label className="form-label">Nombre *</label>
              <input
                className="form-input"
                value={form.nombre}
                onChange={set('nombre')}
                placeholder="Razón social o nombre"
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Email</label>
              <input
                className="form-input"
                type="email"
                value={form.email}
                onChange={set('email')}
                placeholder="contacto@empresa.com"
              />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label className="form-label">Ciudad</label>
                <input
                  className="form-input"
                  value={form.ciudad}
                  onChange={set('ciudad')}
                  placeholder="Ciudad"
                />
              </div>
              <div className="form-group">
                <label className="form-label">País</label>
                <input
                  className="form-input"
                  value={form.pais}
                  onChange={set('pais')}
                  placeholder="MX"
                  maxLength={3}
                />
              </div>
            </div>
          </div>

          <div className="modal-foot">
            <button type="button" className="btn-cancel" onClick={onClose}>
              Cancelar
            </button>
            <button type="submit" className="btn" disabled={saving}>
              {saving ? 'Guardando...' : data ? 'Actualizar' : 'Crear'}
            </button>
          </div>
        </form>

      </div>
    </div>
  )
}
