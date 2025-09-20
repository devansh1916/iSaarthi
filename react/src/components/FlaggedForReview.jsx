import React, { useState, useMemo } from 'react';
import { 
  AlertTriangle, 
  Check, 
  Edit, 
  X, 
  Search, 
  MapPin, 
  Calendar,
  ShieldQuestion,
  ThumbsDown,
  Building,
  Info,
  Send
} from 'lucide-react';
import ModifyAssignmentModal from './components/ModifyAssignmentModal';

const DEPARTMENTS = ["Public Works", "Utilities", "Sanitation", "Parks & Recreation", "Emergency Services", "Road", "Water Works"];
const PRIORITIES = ["Low", "Medium", "High", "Urgent"];

const FlaggedForReview = ({ flaggedIssues, onApprove, onDismiss, loading }) => {
  const [editingIssue, setEditingIssue] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterReason, setFilterReason] = useState('all');

  const filteredIssues = useMemo(() => {
    const sourceData = flaggedIssues || [];
    if (!searchTerm && filterReason === 'all') return sourceData;
    
    return sourceData.filter(issue => {
      const searchLower = searchTerm.toLowerCase();
      const matchesSearch = (issue.title || '').toLowerCase().includes(searchLower) ||
                            (issue.description || '').toLowerCase().includes(searchLower);
      const matchesFilter = filterReason === 'all' || (issue.flagReason && issue.flagReason.replace(/\s+/g, '-').toLowerCase() === filterReason.toLowerCase());
      return matchesSearch && matchesFilter;
    });
  }, [flaggedIssues, searchTerm, filterReason]);

  const getFlagReasonStyle = (reason) => {
    const defaultReason = { icon: <AlertTriangle className="w-4 h-4 text-gray-600" />, color: 'bg-gray-100 text-gray-800 border-gray-200' };
    if (!reason) return defaultReason;

    const lowerReason = reason.toLowerCase();
    if (lowerReason.includes('confidence')) {
      return { icon: <ShieldQuestion className="w-4 h-4 text-yellow-600" />, color: 'bg-yellow-100 text-yellow-800 border-yellow-200' };
    }
    if (lowerReason.includes('urgent')) {
      return { icon: <AlertTriangle className="w-4 h-4 text-red-600" />, color: 'bg-red-100 text-red-800 border-red-200' };
    }
    if (lowerReason.includes('rejected')) {
       return { icon: <ThumbsDown className="w-4 h-4 text-orange-600" />, color: 'bg-orange-100 text-orange-800 border-orange-200' };
    }
    return defaultReason;
  };
  
  const handleModifyConfirm = (issueId, newDepartment, newPriority) => {
    onApprove(issueId, newDepartment, newPriority);
  };

  const renderIssueCard = (issue) => {
    const flagStyle = getFlagReasonStyle(issue.flagReason);
    const isRejected = (issue.flagReason || '').toLowerCase().includes('rejected');

    const primaryActionButton = isRejected ? (
      <button 
        onClick={() => onApprove(issue.id, issue.department, issue.priority)} 
        className="flex items-center space-x-2 px-4 py-2 text-sm bg-blue-500 text-white rounded-lg hover:bg-blue-600"
      >
        <Send className="w-4 h-4" />
        <span>Send Back to Department</span>
      </button>
    ) : (
      <button 
        onClick={() => onApprove(issue.id, issue.department, issue.priority)} 
        className="flex items-center space-x-2 px-4 py-2 text-sm bg-green-500 text-white rounded-lg hover:bg-green-600"
      >
        <Check className="w-4 h-4" />
        <span>Approve Suggestion</span>
      </button>
    );

    return (
      <div key={issue.id} className="bg-white rounded-lg shadow-md border overflow-hidden">
        <div className={`p-4 border-b flex items-center justify-between ${flagStyle.color}`}>
          <div className="flex items-center space-x-2">
            {flagStyle.icon}
            <span className="text-sm font-semibold">{issue.flagReason || "Flagged for Review"}</span>
          </div>
          {issue.modelConfidence && <span className={`text-xs font-medium`}>Confidence: {issue.modelConfidence}%</span>}
        </div>
        <div className="p-6">
          <h3 className="text-lg font-semibold text-gray-900 truncate">{issue.title}</h3>
          <p className="text-sm text-gray-600 mt-1 truncate">{issue.description}</p>
          <div className="flex items-center space-x-4 text-xs text-gray-500 mt-3">
            <div className="flex items-center"><MapPin className="w-3 h-3 mr-1" />{issue.readableLocation || issue.location}</div>
            <div className="flex items-center"><Calendar className="w-3 h-3 mr-1" />{new Date(issue.reportedAt || issue.timestamp).toLocaleDateString()}</div>
          </div>
          <div className="mt-4 p-4 bg-gray-50 rounded-lg border border-gray-200">
            <p className="text-sm font-medium text-gray-800">AI Suggestion:</p>
            <div className="flex items-center space-x-4 mt-2">
              <div className="flex items-center text-sm"><Building className="w-4 h-4 mr-2 text-gray-500" />Assign to <strong className="ml-1">{issue.department || 'N/A'}</strong></div>
              <div className="flex items-center text-sm"><AlertTriangle className="w-4 h-4 mr-2 text-gray-500" />Set priority to <strong className="ml-1">{issue.priority || 'N/A'}</strong></div>
            </div>
          </div>
        </div>
        <div className="p-4 bg-gray-50 border-t border-gray-200 flex items-center justify-end space-x-3">
          <button onClick={() => onDismiss(issue.id)} className="flex items-center space-x-2 px-4 py-2 text-sm bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300"><X className="w-4 h-4" /><span>Dismiss</span></button>
          <button onClick={() => setEditingIssue(issue)} className="flex items-center space-x-2 px-4 py-2 text-sm bg-yellow-400 text-yellow-900 rounded-lg hover:bg-yellow-500"><Edit className="w-4 h-4" /><span>Modify & Assign</span></button>
          {primaryActionButton}
        </div>
      </div>
    );
  };

  return (
    <>
      <ModifyAssignmentModal 
        issue={editingIssue} 
        onClose={() => setEditingIssue(null)} 
        onConfirm={handleModifyConfirm} 
        departments={DEPARTMENTS} 
        priorities={PRIORITIES} 
      />
      <div className="space-y-6">
        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
          <div className="flex flex-col lg:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input type="text" placeholder="Search flagged issues..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500" />
            </div>
            <select value={filterReason} onChange={(e) => setFilterReason(e.target.value)} className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500">
              <option value="all">All Flag Reasons</option>
              <option value="low-model-confidence">Low Confidence</option>
              <option value="urgent-keyword-detected">Urgent Keyword</option>
              <option value="rejected-by-department">Rejected by Department</option>
            </select>
          </div>
        </div>
        
        {/* --- FIX: The entire conditional block is now wrapped in {} --- */}
        <div className="space-y-4">
          {loading ? (
            <div className="text-center text-gray-500 py-8 bg-white rounded-lg shadow-md border">Loading issues...</div>
          ) : filteredIssues.length > 0 ? (
            filteredIssues.map(issue => renderIssueCard(issue))
          ) : (
            <div className="text-center py-12 px-4 bg-white rounded-lg shadow-md border">
                <Info className="mx-auto h-12 w-12 text-gray-400" />
                <h3 className="mt-2 text-lg font-medium text-gray-900">No issues flagged for review</h3>
                <p className="mt-1 text-sm text-gray-500">
                  All flagged issues have been dealt with. Great job!
                </p>
            </div>
          )}
        </div>

      </div>
    </>
  );
};

export default FlaggedForReview;