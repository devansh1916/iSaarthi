import React, { useState, useEffect } from 'react';
import { X } from 'lucide-react';

const ModifyAssignmentModal = ({ issue, onClose, onConfirm, departments, priorities }) => {
  // Initialize state as empty strings
  const [department, setDepartment] = useState('');
  const [priority, setPriority] = useState('');

  // --- THIS IS THE KEY FIX ---
  // This `useEffect` hook runs whenever the 'issue' prop changes.
  // It ensures the modal's internal state is always in sync with the
  // specific issue you've clicked on, preventing stale data.
  useEffect(() => {
    if (issue) {
      setDepartment(issue.department || issue.suggestedDepartment || '');
      setPriority(issue.priority || issue.suggestedPriority || '');
    }
  }, [issue]); 
  
  if (!issue) return null;

  const handleConfirm = () => {
    // This now correctly sends the updated state values
    onConfirm(issue.id, department, priority);
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-[rgba(0,0,0,0.6)] backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-2xl w-full max-w-lg">
        <div className="p-6 border-b border-gray-200">
          <div className="flex justify-between items-start">
            <div>
              <h2 className="text-xl font-bold text-gray-900">Modify & Assign</h2>
              <p className="text-sm text-gray-500">{issue.title}</p>
            </div>
            <button onClick={onClose} className="p-2 text-gray-400 hover:text-gray-600">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>
        <div className="p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Department</label>
            <select
              value={department}
              onChange={(e) => setDepartment(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
            >
              <option value="" disabled>Select a department</option>
              {departments.map(dept => <option key={dept} value={dept}>{dept}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Priority</label>
            <select
              value={priority}
              onChange={(e) => setPriority(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
            >
              <option value="" disabled>Select a priority</option>
              {priorities.map(p => <option key={p} value={p}>{p}</option>)}
            </select>
          </div>
        </div>
        <div className="p-6 bg-gray-50 border-t border-gray-200 flex justify-end space-x-3">
          <button onClick={onClose} className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-100">
            Cancel
          </button>
          <button onClick={handleConfirm} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
            Confirm Assignment
          </button>
        </div>
      </div>
    </div>
  );
};

export default ModifyAssignmentModal;